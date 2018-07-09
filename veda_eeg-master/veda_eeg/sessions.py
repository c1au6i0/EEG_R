'''
Created on Jun 8, 2016

@author: scaglionea
'''



from veda_eeg.utils import lib_files, lib_logger
from utils import lib_files, lib_logger

from .io import OpenEphys

logger = lib_logger.create_logger()


def find_sessions(path=None, filters='*.con*'):

    if path is None:
        return

    _, data_dirs = lib_files.find_files(path, filters, return_dirs=True)
    msg = 'Found {} sessions'.format(len(data_dirs))
    logger.info(msg)

    return data_dirs


def import_sessions(path_or_pathlist=None):

    if path_or_pathlist is None:
        return

    if isinstance(path_or_pathlist, str) or isinstance(path_or_pathlist, unicode):
        path_or_pathlist = find_sessions(path_or_pathlist)

    for session in path_or_pathlist:
        msg = 'Processing {}'.format(session)
        logger.info(msg)


if __name__ == '__main__':
    pass
