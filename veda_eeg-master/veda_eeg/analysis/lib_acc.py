'''
Created on Apr 17, 2017

@author: scaglionea
'''

from veda_eeg import import_session

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


def filter_acc(x, fp=.5, fs=0.01, gpass=0.1, gstop=50., sf=2000.):
    '''
    filters the incoming signal. By default it uses an highpass filter with pass
    frequency of fp=0.5 Hz and stop frequency fs=0.01 Hz. The gain in the stop
    and pass band is defined by ws and wp. Sampling frequency sf is assumed to
    be 2000Hz

    :param x: original signal
    :type x: <np.array>
    :param fp: pass frequency
    :type fp: float
    :param fs: stop frequency
    :type fs: float
    :param gpass: pass band
    :type gpass: float
    :param gstop: stop band
    :type gstop: float
    :param sf: sampling frequency
    :type sf: float
    '''

    wp = fp / (sf / 2.0)
    ws = fs / (sf / 2.0)

    b, a = spsi.iirdesign(wp, ws, gpass, gstop)

    return spsi.filtfilt(b, a, x)


def movement_index(x, sensitivity=100, sf=2000, threshold=None, coeff=200, width=60):
    '''
    Estimate animal movement based on the modulus of the accelerometer.

    :param x: accelerometer modulus
    :type x:
    :param sensitivity:
    :type sensitivity:
    :param sf:
    :type sf:
    :param threshold:
    :type threshold:
    :param coeff:
    :type coeff:
    :param width:
    :type width:
    '''

    # bandpassing the modulus from 0.2Hz to 45Hz. Usable bandwith is from 0.2 to 45
    # the rest if filtered out
    x = filter_acc(x, 0.2, 0.01)
    x = filter_acc(x, 45, 50)

    x = x**2 * sensitivity

    return x

    #     if threshold is None:
    #         threshold = sensitivity * np.median(abs(x)) / 0.6745
    #         print('threshold set automatically to {}:'.format(threshold))
    #
    #     peaks, values = find_peaks(x, threshold, return_extrema=True)
    #     tmp = np.full(peaks.max() + 1, 0.)
    #     tmp[peaks] = values
    #     peaks = tmp
    #
    #     kernel = spsi.hanning(int(width * sf), True)
    #     kernel = kernel / sum(kernel) * coeff
    #
    #     return spsi.convolve(peaks, kernel, 'same')


def estimate_movement_index_from_path(path):

    x = get_acc_data(path)
    x = movement_index(x['mod'])

    return x


def mean_mi(x):

    mi = movement_index(x)
    mi_c_a = spsi.convolve(mi, np.ones(60 * 2000) / (60 * 2000.))
    return mi_c_a[0:mi.size]


if __name__ == '__main__':
    pass
