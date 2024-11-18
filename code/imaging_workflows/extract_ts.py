import argparse
from nilearn.maskers import NiftiSpheresMasker
from nilearn.image import math_img
from nilearn.maskers import NiftiMapsMasker
import numpy as np
import pandas as pd

parser = argparse.ArgumentParser(description="")
parser.add_argument("--input", type=str)
parser.add_argument("--mask", type=str)
parser.add_argument("--output", type=str)
parser.add_argument("--radius", type=int)

seeds = [(6, 16, -10), (-16, -100, 2)]
bids_path = "/home/lukeh/hpcworking/lukeH/projects/QNC_outcomes/data/bids/"


def extract_timeseries(input_img, mask, radius, output):

    # add inidividualised seed
    coord_df = pd.read_csv(bids_path+'phenotype/coordinates.tsv',
                           delimiter="\t")
    # get coordinate
    sid = input_img.split("sub-")[-1].split("_")[0]
    row = coord_df[coord_df.participant_id == "sub-"+sid]

    # "raw" coordinate
    target = np.array((row.x.values[0],
                       row.y.values[0],
                       row.z.values[0]))
    seeds.append(target)

    # "connie" coordinate
    target = np.array((row.Transformed_Nlin6Asym_Treatment_MNI_X.values[0],
                       row.Transformed_Nlin6Asym_Treatment_MNI_Y.values[0],
                       row.Transformed_Nlin6Asym_Treatment_MNI_Z.values[0]))
    seeds.append(target)

    # connie adjusted coordinate
    target = np.array((row.Transformed_Nlin6Asym_Treatment_MNI_X_adj10.values[0],
                       row.Transformed_Nlin6Asym_Treatment_MNI_Y_adj10.values[0],
                       row.Transformed_Nlin6Asym_Treatment_MNI_Z_adj10.values[0]))

    seeds.append(target)

    # Extract timeseries
    # need to ue a brain mask...
    time_series = NiftiSpheresMasker(seeds, radius=radius, mask_img=mask,
                                     allow_overlap=True
                                     ).fit_transform(input_img)

    # Extract normative ts
    dlpfc_mask_img = "/home/lukeh/projects/QNC_pipeline/masks/DLPFCcombo20mm-NC.nii"
    seed_map_img = "/home/lukeh/projects/QNC_pipeline/masks/SGC10_GroupFCmap_2000_FWHM4-NC.nii"

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

    # save the out file
    out_ts = np.hstack((sgc_time_series_weighted, time_series))
    np.savetxt(output, out_ts, delimiter=",")
    return out_ts


if __name__ == "__main__":
    args = parser.parse_args()

    ts = extract_timeseries(args.input, args.mask, args.radius, args.output)
