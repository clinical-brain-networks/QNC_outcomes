"""
Post-fmriprep denoising using Nilearn.

Uses high-level nilearn functions to clean timeseries data.

This approach and the possible strategies are from this paper:
see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10153168/pdf/nihpp-2023.04.18.537240v3.pdf

The specific 'out-of-the-box' denoise strategies are found here:
https://github.com/SIMEXP/fmriprep-denoise-benchmark/blob/b9d44504384b3641dbd1d063105cb6eb99713488/fmriprep_denoise/dataset/benchmark_strategies.json#L4

"""
import json
import os
import nibabel as nb
from nilearn.image import clean_img
import argparse
from nilearn.interfaces.fmriprep import load_confounds_strategy

# Create parser for options
parser = argparse.ArgumentParser(description="""Run nilearn based BOLD denoising""")

# These parameters must be passed to the function
parser.add_argument(
    "--input_img", type=str, default=None, help="""input bold nifti data"""
)

parser.add_argument(
    "--denoise_strategy",
    type=str,
    default=None,
    help="""denoise strategy located in json""",
)

parser.add_argument(
    "--filter_strategy",
    type=str,
    default=None,
    help="""filter strategy located in json""",
)

parser.add_argument(
    "--output_img", type=str, default=None, help="""output bold nifti data"""
)


def get_tr(img):
    """
    Get image TR based on associated .json file
    Assumes bids organisation
    """

    img_json = f"{img.split('.nii.gz')[0]}.json"
    img_params = json.load(open(img_json,))
    return img_params["RepetitionTime"]


def denoise_nifti(input_img, confound_strategy, filter_strategy, output_img):

    # Interpret the denoise strategy based on the json
    # Load confound strat (assumed to be in same location)
    parameters = json.load(
        open(os.path.dirname(os.path.realpath(__file__)) + "/denoise_config.json",)
    )

    # Get confounds
    confounds, sample_mask = load_confounds_strategy(
        input_img, **parameters[confound_strategy]
    )

    # Load filter strat
    filter_params = parameters[filter_strategy]

    # Clean the timeseries
    cleaned_img = clean_img(
        input_img,
        detrend=True,
        standardize=True,
        confounds=confounds,
        high_pass=filter_params["high_pass"],
        low_pass=filter_params["low_pass"],
        t_r=get_tr(input_img),
        kwargs={
            "clean__sample_mask": sample_mask,
            'clean__standardize': 'zscore_sample',
            "clean__filter": filter_params["filter"],
        },
    )

    # save out
    nb.save(cleaned_img, output_img)
    return output_img


if __name__ == "__main__":
    # Read in user-specified parameters
    args = parser.parse_args()

    # Denoise nifti
    denoise_nifti(
        args.input_img, args.denoise_strategy, args.filter_strategy, args.output_img
    )
