import argparse
import nibabel as nib
from tms_coord_pipeline import *
from nilearn.maskers import NiftiSpheresMasker

parser = argparse.ArgumentParser(description="")
parser.add_argument("--input", type=str)
parser.add_argument("--output", type=str)
parser.add_argument("--seed_method", type=str)

radius = 5  # 10mm seems huge...
target = (6, 16, -10)


def generate_sgc_map_default(
    input_img,
    gm_mask_img,
):

    # Extract SGC time series
    sgc_time_series = NiftiSpheresMasker([target], radius=radius
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
            np.ravel(sgc_time_series),
        )
        / sgc_time_series.shape[0]
    )

    # Save as nifti
    sgc_fc_seed_map = brain_masker.inverse_transform(fc)
    #nii_output = os.path.join(out_dir, "normative_sgc_fc_map_MNI.nii")
    #nib.save(sgc_fc_seed_map, nii_output)
    return sgc_fc_seed_map


if __name__ == "__main__":
    args = parser.parse_args()

    # Use the QNC pipeline to calculate the SGC signal
    if args.seed_method == "hcp":
        fc_map = generate_sgc_map(
            args.input,
            seed_map_img="/home/lukeh/projects/QNC_pipeline/masks/SGC10_GroupFCmap_2000_FWHM4-NC.nii",
            dlpfc_mask_img="/home/lukeh/projects/QNC_pipeline/masks/DLPFCcombo20mm-NC.nii",
            gm_mask_img="/home/lukeh/projects/QNC_pipeline/masks/GMmask_new_trim_YT-NC.nii",
            out_dir=""
        )

    elif args.seed_method == "default":
        fc_map = generate_sgc_map_default(args.input,
                                          gm_mask_img="/home/lukeh/projects/QNC_pipeline/masks/GMmask_new_trim_YT-NC.nii")

    nib.save(fc_map, args.output)

