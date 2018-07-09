'''
Created on Aug 1, 2017

@author: scaglionea
'''

import shutil
import glob
import os
import datetime
from read_header import read_header
import numpy as np
import pdb
import re


def _remove_fold_sep(folder_name):
    if folder_name[-1] == os.path.sep:
        folder_name = folder_name[:-1]
    return folder_name


def merge_sessions_no_rhd(folder_list, keep_order=False):

    if not keep_order:
        folder_list.sort()

    folder_list = map(_remove_fold_sep, folder_list)

    if len(folder_list) == 1:
        print('at least two folders are needed to merge.')
        return

    to_merge_list = glob.glob(os.path.join(folder_list[0], '*.dat'))

    if len(to_merge_list) == 0:
        print('No data file found')
        return

    merge_folder_name = folder_list[0] + '_mrg'

    if not os.path.isdir(merge_folder_name):
        os.mkdir(merge_folder_name)

    with open(os.path.join(folder_list[0], 'info.rhd')) as header_file:
        header = read_header(header_file)

    sf = header['sample_rate']

    for file_name in to_merge_list:
        print('Processing: {}'.format(file_name))
        mrg_base_name = os.path.split(file_name)[1]
        mrg_file_name = os.path.join(merge_folder_name, mrg_base_name)
        add_files = [glob.glob(os.path.join(fold, mrg_base_name))[0] for fold in folder_list[1:]
                     if len(glob.glob(os.path.join(fold, mrg_base_name))) > 0]
        timestamps = [fold[-6:] for fold in folder_list[1:]
                      if len(glob.glob(os.path.join(fold, mrg_base_name))) > 0]
        timestamps = [folder_list[0][-6:]] + timestamps
        timestamps = [datetime.datetime.strptime(
            ts, "%H%M%S") for ts in timestamps]
        file_list = [file_name] + add_files

        merge_files_no_rhd(file_list, mrg_file_name, timestamps, sf)

    to_copy_list = glob.glob(os.path.join(folder_list[0], '*.rhd'))
    to_copy_list += glob.glob(os.path.join(folder_list[0], '*.txt'))
    to_copy_list += glob.glob(os.path.join(folder_list[0], '*.xls*'))

    for file_name in to_copy_list:
        shutil.copy2(file_name, merge_folder_name)


def merge_files_no_rhd(file_list, mrg_file_name=None, timestamps=None, sf=None):

    print('merging {} --> {}'.format(file_list, mrg_file_name))
    print('timestamps: {}'.format(timestamps))
    if timestamps is not None:
        if sf is None:
            raise ValueError(
                'Merging based on timestamps but no sampling frequency provided')

    shutil.copyfile(file_list[0], mrg_file_name)

    if ('amp' in file_list[0]
        or 'vdd' in file_list[0]
            or 'aux' in file_list[0]):

        with open(mrg_file_name, 'r+') as mrg_data:

            for add_file, delta in zip(file_list[1:], np.array(timestamps[1:]) - timestamps[0]):
                exp_length = int(delta.total_seconds()) * int(sf) * 2
                mrg_data.seek(0, 2)
                pad_length = exp_length - mrg_data.tell()
                mrg_data.write('\0' * pad_length)
                with open(add_file, 'r') as add_data:
                    mrg_data.write(add_data.read())

    if ('time' in file_list[0]):

        with open(mrg_file_name, 'r+') as mrg_data:

            for add_file, delta in zip(file_list[1:], np.array(timestamps[1:]) - timestamps[0]):
                exp_length = int(delta.total_seconds()) * int(sf) * 4
                mrg_data.seek(0, 2)
                pad_length = exp_length - mrg_data.tell()
                mrg_data.write('\0' * pad_length)
                with open(add_file, 'r') as add_data:
                    mrg_data.write(add_data.read())

    if ('board' in file_list[0]):

        with open(mrg_file_name, 'r+') as mrg_data:

            for add_file, delta in zip(file_list[1:], np.array(timestamps[1:]) - timestamps[0]):
                mrg_data.seek(0, 2)
                with open(add_file, 'r') as add_data:
                    mrg_data.write(add_data.read())


def split_subjects(path_name):

    path_name = _remove_fold_sep(path_name)

    meta_file = glob.glob(os.path.join(path_name, '*.txt'))

    with open(meta_file[0]) as meta:
        exp_label = meta.readline()

    if not os.path.isdir(path_name):
        raise ValueError('input is not a valid path')

    fields = re.findall(r'[A-Za-z0-9]+', os.path.basename(path_name))
    meta_fields = re.findall(r'[A-Za-z0-9-]+', exp_label)
    fold_list = ['_'.join([fields[0]] + meta_fields[1:])]
    fold_list += ['_'.join(['RAT' + fields[1]] + meta_fields[1:])]
    for folder in fold_list:
        if not os.path.isdir(folder):
            os.mkdir(folder)

    sub1_file_list = glob.glob(os.path.join(path_name, '*-A-*.dat'))
    sub1_file_list += glob.glob(os.path.join(path_name, 'time.dat'))
    sub1_file_list += glob.glob(os.path.join(path_name, '*.rhd'))
    sub1_file_list += glob.glob(os.path.join(path_name, '*.txt'))
    sub1_file_list += glob.glob(os.path.join(path_name, '*.xls'))

    for file_name in sub1_file_list:
        shutil.copy2(file_name, fold_list[0])

    sub2_file_list = glob.glob(os.path.join(path_name, '*-D-*.dat'))
    sub2_file_list += glob.glob(os.path.join(path_name, 'time.dat'))
    sub2_file_list += glob.glob(os.path.join(path_name, '*.rhd'))
    sub2_file_list += glob.glob(os.path.join(path_name, '*.txt'))
    sub2_file_list += glob.glob(os.path.join(path_name, '*.xls'))
    for file_name in sub2_file_list:
        shutil.copy2(file_name, fold_list[1])


if __name__ == '__main__':
    pass
