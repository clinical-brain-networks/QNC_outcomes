import argparse
import nibabel as nib
import pandas as pd
import numpy as np
import os
from nilearn.image import math_img
from nilearn.image import threshold_img
from nilearn.maskers import NiftiMasker, NiftiMapsMasker
from nilearn.reporting import get_clusters_table
from tqdm import tqdm
#from tms_pipeline_plots import generate_brain_plots

parser = argparse.ArgumentParser(description="Run personalised TMS coordinate code")
parser.add_argument("--input_img", type=str, help="input denoised NIFTI img file")
parser.add_argument("--out_dir", type=str, help="path to where results will be saved")

# Masks are global as we don't intend the user to change them
pipeline_dir = os.path.dirname(os.path.realpath(__file__))
seed_map_img = os.path.join(pipeline_dir, "../masks/SGC10_GroupFCmap_2000_FWHM4-NC.nii")
dlpfc_mask_img = os.path.join(pipeline_dir, "../masks/DLPFCcombo20mm-NC.nii")
gm_mask_img = os.path.join(pipeline_dir, "../masks/GMmask_new_trim_YT-NC.nii")


def generate_sgc_map(
    input_img,
    seed_map_img,
    dlpfc_mask_img,
    gm_mask_img,
    out_dir,
):
    """
    Generate SGC Seed-Weighted Functional Connectivity Map

    Parameters:
    - input_img (str): Path to the denoised input NIfTI.
    - seed_map_img (str): Path to the probabilistic SGC seed map NIfTI.
    - dlpfc_mask_img (str): Path to the DLPFC mask NIfTI.
    - gm_mask_img (str): Path to the brain-wide gray matter mask NIfTI.
    - out_dir (str): Path to directory of output directory.

    Returns:
    - sgc_fc_seed_map (str): SGC Seed-weighted FC map (as file path)
    """

    # Check the denoised image is the same shape as the mask
    # and HCP images used in the pipeline
    assert (
        nib.load(input_img).shape[0:3] == nib.load(seed_map_img).shape
    ), "Image shapes do not match"

    # Process normative data by masking out the dlpfc
    dlpfc_neg_mask = math_img(
        "-img + 1",
        img=dlpfc_mask_img,
    )
    seed_map_dlpfc = math_img(
        "img1 * img2",
        img1=seed_map_img,
        img2=dlpfc_neg_mask,
    )

    # Normalise seed map as per matlab code:
    # hcp_fc_map=hcp_fc_map/sum(abs(hcp_fc_map(:)));
    # norm_fc_map = norm_fc_map / np.nansum(abs(np.ravel(norm_fc_map)))
    seed_map_dlpfc_norm = math_img(
        "img / np.nansum(abs(np.ravel(img)))",
        img=seed_map_dlpfc,
    )

    # Extract SGC time series using the seed map as
    # a probabilistic seed
    sgc_time_series_weighted = NiftiMapsMasker(
        maps_img=seed_map_dlpfc_norm,
        standardize="zscore_sample",
        verbose=2,
    ).fit_transform(input_img)

    # Extract brain-wide time series
    brain_masker = NiftiMasker(
        mask_img=gm_mask_img,
        standardize="zscore_sample",
        verbose=2,
    )
    brain_time_series = brain_masker.fit_transform(input_img)

    # Functional connectivity of sgc seed
    fc = (
        np.dot(
            brain_time_series.T,
            np.ravel(sgc_time_series_weighted),
        )
        / sgc_time_series_weighted.shape[0]
    )

    # Save as nifti
    sgc_fc_seed_map = brain_masker.inverse_transform(fc)
    #nii_output = os.path.join(out_dir, "normative_sgc_fc_map_MNI.nii")
    #nib.save(sgc_fc_seed_map, nii_output)
    return sgc_fc_seed_map


def get_stimulation_site(input_img, dlpfc_mask_img, out_dir):
    """
    Identify Stimulation Site in DLPFC

    This function aims to determine the optimal stimulation site within the
    DLPFC by iterating through potential cluster thresholds. It uses an
    input fc map and a DLPFC mask to identify negative clusters, selects
    the largest cluster, and records its spatial coordinates.

    Parameters:
    - input_img (str): Path to the input image.
    - dlpfc_mask_img (str): Path to the DLPFC mask image.
    - out_dir (str): Path to directory of output directory.

    Returns:
    - df_coords (str): A Pandas DataFrame containing stimulation site
      coordinates and related information (as file path)
    """

    # Init. results file
    df_coords = pd.DataFrame(
        columns=["Method", "x", "y", "z", "Threshold", "Cluster Size (mm3)"]
    )

    # Loop through potential cluster thresholds
    for cluster_thresh in tqdm(np.arange(99.999, 99.8, -0.005)):

        # Threshold the image at the looped percentile
        img_thresh = threshold_img(
            input_img,
            threshold=f"{cluster_thresh}%",
            mask_img=dlpfc_mask_img,
        )

        # Create a pandas df of cluster information
        df = get_clusters_table(
            img_thresh,
            stat_threshold=0,
            two_sided=True,
        )

        # Convert to numeric
        df["Cluster Size (mm3)"] = pd.to_numeric(df["Cluster Size (mm3)"])

        # Isolate negative clusters only
        df_neg = df.loc[df["Peak Stat"] < 0]

        if df_neg.empty:
            # Continue to the next threshold
            pass

        else:
            # Find the maximum negative cluster
            df_neg_max_cluster = df_neg.loc[df_neg["Cluster Size (mm3)"].idxmax()]

            # Save into results
            row = pd.DataFrame(
                {
                    "Method": ["Cluster"],
                    "Threshold": [cluster_thresh],
                    "Cluster Size (mm3)": [df_neg_max_cluster["Cluster Size (mm3)"]],
                    "x": [df_neg_max_cluster["X"]],
                    "y": [df_neg_max_cluster["Y"]],
                    "z": [df_neg_max_cluster["Z"]],
                }
            )
            df_coords = pd.concat([df_coords, row], ignore_index=True)

    cluster_file = os.path.join(out_dir, "TMS_coords_method-Cluster.csv")
    df_coords.to_csv(cluster_file)
    return cluster_file


if __name__ == "__main__":
    args = parser.parse_args()
    sgc_fc_seed_map = generate_sgc_map(
        args.input_img, seed_map_img, dlpfc_mask_img, gm_mask_img, args.out_dir
    )
    df_coords = get_stimulation_site(sgc_fc_seed_map, dlpfc_mask_img, args.out_dir)
    generate_brain_plots(sgc_fc_seed_map, df_coords, dlpfc_mask_img, args.out_dir)
