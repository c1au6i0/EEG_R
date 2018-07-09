'''
Created on Aug 23, 2016

@author: scaglionea
'''

import analysis.spectral as sp
import io.io_veda as iov
from veda_eeg.utils import lib_files, lib_logger

logger = lib_logger.create_logger()


def batch_analysis(root_folder=None, func_list=None):

    if root_folder is None:
        msg = 'root_folder not give'
        logger.error(msg)
        raise Exception(msg)

    if func_list is None:
        func_list = [sp.spectra_analysis_df]

    sessions_to_analyze = iov.find_sessions(root_folder)

    for func in func_list:
        gen = (iov.import_session(path) for path in sessions_to_analyze)

        def func(x): return func(x, return_results=False)

        map(func, gen)
