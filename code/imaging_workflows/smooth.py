import nibabel as nb
from nilearn.image import smooth_img
import argparse

# Create parser for options
parser = argparse.ArgumentParser(description="""Run nilearn based BOLD denoising""")

# These parameters must be passed to the function
parser.add_argument(
    "--input_img", type=str, default=None, help="""input bold nifti data"""
)

parser.add_argument("--fwhm", type=int, default=None, help="""FWHM smooth integer""")

parser.add_argument(
    "--output_img", type=str, default=None, help="""output bold nifti data"""
)


def smooth_nifti(input_img, fwhm, output_img):
    smoothed_img = smooth_img(input_img, fwhm)
    nb.save(smoothed_img, output_img)
    return smoothed_img


if __name__ == "__main__":
    # Read in user-specified parameters
    args = parser.parse_args()

    # run denoise
    smooth_nifti(args.input_img, args.fwhm, args.output_img)
