'''
Created on May 15, 2016

@author: scaglionea
'''


import os
import sys
import re
import subprocess
import fnmatch
#import pdb

import numpy as np

import lib_logger


logger = lib_logger.create_logger()


def find_files(start_dir='.', filters='*', recursive=True,
               condition='or', return_dirs=False, ignore_case=True,
               abs_path=True):
    '''

    Returns a list of absolute path with the files that match the given filters. Filters can
    be a string/unicode or a list of strings. If a list of strings the resulting list will contain
    all files based on the logical condition set.

    :param start_dir:
    :param filters:
    :param recursive:
    :param condition:
    :param return_dirs:
    '''

    if not os.path.isdir(start_dir):
        msg = "start_dir not a valid path"
        logger.warn(msg)
        return

    if abs_path:
        start_dir = os.path.abspath(start_dir)

    if type(filters) is str or type(filters) is unicode:
        filters = [filters]

    if condition not in ['or', 'and']:
        msg = "Did not understand the condition {}".format(condition)
        logger.errror(msg)
        return

    if recursive:
        if sys.platform in ['darwin', 'linux2']:

            #         files_list = []
            #         for filter_ in filters:
            #             if ignore_case:
            #                 files_list.extend(find_files_unix(start_dir, iname=filter_))
            #             else:
            # files_list.extend(find_files_unix(start_dir, name=filter_
            files_list = find_files_unix(start_dir, recursive=recursive)
        else:
            files_list = _find_files_python_(start_dir, filters, recursive)
    else:
        files_list = os.listdir(start_dir)

    #     # applying filters
    #     filt_list = []
    #     for filter_ in list(filters):
    #         filt_list.extend(fnmatch.filter(files_list, filter_))
    #     files_list = list(set(filt_list))

    if ignore_case:
        matchfun = fnmatch.fnmatch
    else:
        matchfun = fnmatch.fnmatchcase

    if condition == 'or':
        def or_filter(name):
            if len(filters) < 2:
                return matchfun(name, filters[0])
            if sum([matchfun(name, pat) for pat in filters]) > 0:
                return True
            return False
        files_list = filter(or_filter, files_list)

    if condition == 'and':
        def and_filter(name):
            if len(filters) < 2:
                return matchfun(name, filters[0])
            if sum([matchfun(name, pat) for pat in filters]) == len(filters):
                return True
            return False
        files_list = filter(and_filter, files_list)

    if return_dirs:
        dirs_list = map(lambda x: os.path.split(x)[0], files_list)
        dirs_list = filter(os.path.isdir, dirs_list)
        dirs_list = np.unique(dirs_list).tolist()
        return files_list, dirs_list

    return files_list


def _find_files_python_(start_dir='.', filters=['*'], recursive=True, condition='or', return_dirs=False):

    files_list = []
    # implementation 1 very slow
    #         for filter_ in filters:
    #             for subdirs, _, files in os.walk(start_dir):
    #                 files_list.extend([os.path.join(subdirs, file_)
    #                                    for file_ in files if fnmatch.fnmatch(file_, filter_)])
    # implementation 2
    for subdirs, _, files in os.walk(start_dir):
        files_list.extend([os.path.join(subdirs, file_)
                           for file_ in files])

    return files_list
    # Old code

    files_list = []

    if condition not in ['or', 'and']:
        raise Exception(
            'Invalid entry for condition, it must be either "or" or "and"')

    if isinstance(filters, str):
        filters = [filters]
    elif isinstance(filters, unicode):
        filters = [filters]

    if not type(start_dir) is list or tuple:
        start_dir = [start_dir]

    start_dirs = map(os.path.abspath, start_dir)
    # pdb.set_trace()
    for start_dir in start_dirs:
        if recursive:
            for subdirs, _, files in os.walk(start_dir):
                files_list.extend([os.path.join(subdirs, file_)
                                   for file_ in files if not file_.startswith('.')])
        else:
            files_list.extend([os.path.join(start_dir, file_) for file_ in os.walk(
                start_dir).next()[2] if not file_.startswith('.')])

    # removing duplicates
    files_list = list(set(files_list))
    filt_list = []

    if condition == 'or':
        for filter_ in list(filters):
            filt_list.extend(fnmatch.filter(files_list, filter_))

    if condition == 'and':
        filt_list = files_list
        for filter_ in list(filters):
            filt_list = fnmatch.filter(filt_list, filter_)

    filt_list = sorted(filt_list)
    if return_dirs:
        dirs = [os.path.split(path)[0] for path in filt_list]
        dirs = set(dirs)
        dirs = list(dirs)
        return filt_list, dirs
    filt_list = [os.path.abspath(file_) for file_ in filt_list]

    return list(set(filt_list))


def find_files_unix(directory='.', recursive=True, *args, **kwargs):
    '''
    find files in directory using the unix find command
    :param directory:
    '''

    Popen = subprocess.Popen
    call = ['find']
    call.extend(args)
    call.extend([directory])
    if not recursive:
        call.extend(['-d', '1'])
    if os.path.islink(directory):
        call.insert(1, '-L')
    for key, value in kwargs.iteritems():
        if type(value) is not str:
            value = str(value)
        call.extend(['-' + key, value])
    out, err = Popen(
        call, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    if err:
        raise Exception(err)

    return out.split('\n')[:-1]


def get_fields_from_filename(FileName, Format='Date_Subject_Group_Experiment', prefix='', sep='_', lower=True, is_file_name=True):

    # stripping filename and format
    FileName = FileName.strip()
    Format = Format.strip()

    if is_file_name:
        FileName = os.path.splitext(FileName)[0]
    _, Name = os.path.split(FileName)
    # print(Name)
    Names = re.split(r'[{}]?'.format(sep), Format)
    [name for name in Names if name is not '']
    if lower:
        Names = [re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name).lower()
                 for name in Names]
    else:
        Names = [re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
                 for name in Names]
    Fields = re.split('[_]?', Name)
    Fields = [field for field in Fields if field is not '']
    #Names = map(str.capitalize, Names)
    unique_names = set(Names)

    if len(unique_names) != len(Names):
        NNames = list(set(Names))
        NFields = list()
        for name in NNames:
            NFields.append(
                [bel for bel, al in zip(Fields, Names) if al == name])

        Names = NNames
        Fields = NFields
        Fields = map(sep.join, Fields)

    Names = [prefix + name for name in Names]
    if len(Fields) != len(Names):

        #logger.warn('get_fields_from_filename:Number of Fields mismatch')
        pass

    return dict(zip(Names, Fields))


def spinning_wheel(seq=["|", "/", "-", "\\"], index=[], last=False):

    if len(index) == 0:
        sys.stdout.write(' ')
        sys.stdout.flush()
        index.append(0)
    else:
        index[0] = index[0] + 1
        if index[0] == len(seq):
            index[0] = 0

    msg = "\r"
    sys.stdout.write(msg)
    sys.stdout.flush()
    if last:
        index.pop()
        return
    msg = seq[index[0]]
    sys.stdout.write(msg)
    sys.stdout.flush()


def hash(file_full_name, alg='CRC32', partial_read=False, block_size=1 * 2 ** 20, verbose=False):

    import hashlib
    import zlib

    fun_dict = {'SHA1': hashlib.sha1(),
                'SHA224': hashlib.sha224(),
                'CRC32': zlib.crc32,
                'MD5': hashlib.md5()}

    alg = alg.upper()
    if alg not in fun_dict:
        raise ValueError('hash type not known')

    if partial_read:
        string_ = 'partial'
    else:
        string_ = 'full'
        block_size = 10 * block_size
    if type(file_full_name) is str:
        msg = "|Computing {} {} for {} ".format(string_, alg, file_full_name)
    else:
        msg = "|Computing {} {}".format(string_, alg)
    if len(msg) > 60:
        msg = "|Computing {} {} for ...{} ".format(
            string_, alg, file_full_name[-38:])
    if verbose:
        sys.stdout.write(msg)
        sys.stdout.flush()
        # block_size = 4 * 2 ** 20  # 1-megabyte blocks
        spinning_wheel()
    out = 0
    if type(file_full_name) is str:
        with open(file_full_name, 'rb') as bin_file:
            while True:
                if verbose:
                    spinning_wheel()
                data_block = bin_file.read(block_size)
                if not data_block:
                    break
                if alg == 'CRC32':
                    out = fun_dict[alg](data_block, out)
                else:
                    fun_dict[alg].update(data_block)
    else:
        if verbose:
            spinning_wheel()
        data_block = file_full_name
        if alg == 'CRC32':
            out = fun_dict[alg](data_block, out)
        else:
            fun_dict[alg].update(data_block)

    msg = "\b \b\n" * len(msg)
    if verbose:
        sys.stdout.write(msg)
        sys.stdout.flush()

    if alg == 'CRC32':
        out = "{:x}".format(out & 0xFFFFFFFF)
    else:
        out = fun_dict[alg].hexdigest()

    return out
