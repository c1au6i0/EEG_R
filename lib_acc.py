# -*- coding: utf-8 -*-
'''
Created on Apr 17, 2017

@author: scaglionea
'''


import numpy as np
import scipy.signal as spsi

import pdb


def get_acc_data(path):
    '''
    returns the accelerometer data for the session with the given path, file_name

    :param path: the path or the filename of the session
    :type path: <str>

    :return: a dictionary containing the acc vector components and the modulus
    :type return: <dict>
    '''

    acc = {}
    data = import_session(path, channels='all')
    acc['vec'] = data['aux_series']
    acc['mod'] = np.sqrt(np.sum((acc['vec']**2), 0))

    return acc


def find_peaks(x, threshold=0, what='max', return_extrema=False):
    '''
    find local minima and max of the vector x.

    :param x: the vector
    :type x: a numpy array like
    :param threshold: only peaks/valleys greater/smaller than threshold are considered
    :type threshold: numeric
    :param what: what extrema are going to be found, could me 'max','min' or 'minmax'
    :type what: <str>
    '''

    # checking what to extract
    if what not in ['max', 'min', 'minmax']:
        raise ValueError(
            '{} not understood it should be either "max","min" or "minmax"'.format(what))

    # removing all duplicate values
    non_same = np.hstack((True, np.diff(x) != 0))
    x = x[non_same]

    # pdb.set_trace()
    # reducing vector based on threshold
    if threshold > 0:
        th_sig = x > threshold / 2
    elif threshold == 0:
        th_sig = np.full(x.shape, True)
    else:
        th_sig = x < threshold / 2

    ind = np.where(th_sig)[0]

    th_sig = x[ind]  # extremities are never min or max

    # pdb.set_trace()

    if what in ['max']:
        extrema = ((th_sig[1:-1] > th_sig[2:]) &
                   (th_sig[1:-1] > th_sig[0:-2]))

    elif what in ['min']:
        extrema = ((th_sig[1:-1] < th_sig[2:]) &
                   (th_sig[1:-1] < th_sig[0:-2]))

    elif what in ['minmax']:
        extrema_h = ((th_sig[1:-1] > th_sig[2:]) &
                     (th_sig[1:-1] > th_sig[0:-2]))
        extrema_l = ((th_sig[1:-1] < th_sig[2:]) &
                     (th_sig[1:-1] < th_sig[0:-2]))
        extrema = (extrema_l | extrema_h)

    # the first and the last points can't be local minimum or maximum
    # extrema = np.hstack((extrema, False))
    # extrema[0] = False

    # print(extrema.size)
    extrema = ind[np.hstack((False, extrema, False))]
    ind = extrema

    if threshold > 0:
        extrema = x[extrema] >= threshold
    elif threshold < 0:
        extrema = x[extrema] <= threshold

    extrema = ind[np.where(extrema)[0]]

    if return_extrema:
        return np.where(non_same)[0][extrema], x[extrema]

    return np.where(non_same)[0][extrema]


def filter_acc(x, wp, ws, gpass=0.1, gstop=50., sf=2000.):

    # wp = 0.5 / (sf / 2.0)
    # ws = 0.01 / (sf / 2.0)

    b, a = spsi.iirdesign(wp, ws, gpass, gstop)

    return spsi.filtfilt(b, a, x)


def movement_index(x, sensitivity=1, sf=2000, threshold=None):

    # x = filter_acc(x)

    if threshold is None:
        threshold = sensitivity * np.median(abs(x)) / 0.6745
        print('threshold set automatically to {}:'.format(threshold))

    peaks, values = find_peaks(x, threshold, return_extrema=True)
    tmp = np.full(peaks.max() + 1, 0.)
    tmp[peaks] = values
    peaks = tmp

    kernel = spsi.hanning(int(0.5 * 2000), True)
    kernel = kernel / sum(kernel)

    return spsi.convolve(peaks, kernel, 'same')


if __name__ == '__main__':
    pass

