'''
Created on Aug 31, 2016

@author: scaglionea
'''
import numpy as np


def inj_num(D0, D1, DInterval):

    return (np.log10(D1) - np.log10(D0)) / DInterval + 1


def dosages(D0, D1, DInterval):

    arr = np.arange(inj_num(D0=D0, D1=D1, DInterval=DInterval))
    return 10**(arr * DInterval + np.log10(D0))


def inj_times(baseline, time_interval, N_inj):

    return np.arange(baseline, N_inj * time_interval + 1, time_interval)
