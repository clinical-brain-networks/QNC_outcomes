import numpy as np
from scipy.stats import kde


def find_closest(A, target):
    idx = A.searchsorted(target)
    idx = np.clip(idx, 1, len(A)-1)
    left = A[idx-1]
    right = A[idx]
    idx -= target - left < right - target
    return idx


def get_kde_jitter(y, direction, cov_factor=0.25, kde_width=1, kde_res=1000):

    # get kde denisty
    # kde plot
    prob_density = kde.gaussian_kde(y)
    prob_density.covariance_factor = lambda: cov_factor
    prob_density._compute_covariance()
    kde_y = np.linspace(np.min(y), np.max(y), kde_res)

    if direction == 'left':
        kde_x = prob_density(kde_y) * -1 * kde_width

    elif direction == 'right':
        kde_x = prob_density(kde_y) * kde_width

    x_y = np.zeros((len(y)))
    for i in range(len(y)):
        idx = find_closest(kde_y, y[i])
        jitter = np.random.uniform(0, kde_x[idx])
        x_y[i] = jitter
    return x_y


def get_kde_contours(y, cov_factor=0.25, kde_width=3, kde_res=1000):
    prob_density = kde.gaussian_kde(y)
    prob_density.covariance_factor = lambda: cov_factor
    prob_density._compute_covariance()
    kde_y = np.linspace(np.min(y), np.max(y), kde_res)
    kde_x = prob_density(kde_y) * -1 * kde_width
    kde_x2 = np.zeros((kde_x.shape))

    return kde_y, kde_x, kde_x2


def cat_jitter(y, shift=0.1):
    x = np.zeros((len(y)))
    for i in range(int(np.min(y)),
                   int(np.max(y)+1)):
        overlap = i == y
        if sum(overlap) > 1:
            for j, k in enumerate(np.where(overlap)[0]):
                x[k] = x[k] + (shift*j)
    return x


def uniform_jitter(y, shift=0.1, seed=105):
    np.random.seed(seed)
    return np.random.uniform(0, shift, size=y.shape)


def swarm_jitter(y, nbins=None, shift=0.01, bin_thresh=None):
    # if data is in the same vertical bin, it will be shifted.
    # The shifting should be done so that the highest y value
    # is the largest x value

    if nbins is None:
        if bin_thresh is None:
            bin_thresh = 1

        value = bin_thresh + 1
        nbins = 1
        while value > bin_thresh:
            hist, bin_edges = np.histogram(y, bins=nbins)
            value = np.min(np.diff(bin_edges))
            nbins = nbins + 1

    # calculate histogram and bin edges
    hist, bin_edges = np.histogram(y, bins=nbins)

    # assign values to bins
    y_bin = np.digitize(y, bin_edges)

    x = np.zeros((len(y)))

    for i in range(1, nbins+1):
        new_x = np.zeros((len(y)))

        # index the bin
        index = y_bin == i

        # get the y values and sort them
        values = y[index]
        rank = values.argsort().argsort()
        new_x[index] = rank * shift

        # add to the x array
        x = x + new_x
    return x
