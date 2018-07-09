'''
Created on Jan 11, 2016

@author: scaglionea
'''

import os
import pdb  # @UnusedImport
import re

#import numpy as np
import pandas as pd

from utils import lib_files
from utils import lib_logger

#from lib_fun import set_fun_ver
from utils import lib_pandas_util


# CREATE LOGGER ----------------------------------------------------------
logger = lib_logger.create_logger()

# CONSTANTS --------------------------------------------------------------
DATA_FILE_EXT_FILTER = [
    '*.n[es][v123456]', '*.txt', '*.ccf', '*.h5', '*.xls*', '*.bmp']
DATA_FILE_FILTER = ['*.n[es][v123456]', '*.h5', ]
DATA_FILE_REG = '[.]*[nh][es][v123456]'
H5_DATA_FOLDER = '/Volumes/DATAHD_H5/Recordings'
RAW_DATA_FOLDER = '/Volumes/DATAHD/Recordings'

# DATAFRAME FUNCTIONS ----------------------------------------------------


def file_meta_info(file_name, label_format='date_subject_group_experiment'):

    file_name = os.path.abspath(file_name)
    _, exp_label = os.path.split(file_name)
    exp_label, ext = os.path.splitext(exp_label)

    if not re.match(DATA_FILE_REG, ext) and ext != '.h5':
        return {'file_type': 'Other'}

    format_file = os.path.splitext(file_name)[0] + '.txt'

    if os.path.isfile(format_file):
        with open(format_file, 'r') as txt_file:
            label_format = txt_file.readline().strip()
            exp_label = txt_file.readline().strip()
        if '_' not in label_format:
            with open(format_file, 'r') as txt_file:
                all_txt_file = txt_file.read()
            label_format = 'date_subject_group_experiment'
            _, exp_label = os.path.split(file_name)
            exp_label, ext = os.path.splitext(exp_label)
            with open(format_file, 'w') as txt_file:
                txt_file.write(
                    "{}\n{}\n\n{}".format(label_format, exp_label, all_txt_file))
    else:
        with open(format_file, 'w') as txt_file:
            txt_file.write(
                "{}\n{}".format(label_format, exp_label))

    field_dict = lib_files.get_fields_from_filename(exp_label,
                                                    label_format, prefix='meta_', is_file_name=False)
    field_dict['file_type'] = 'Data'
    field_dict['file_path'], field_dict['file_name'] = os.path.split(file_name)

    field_dict['meta_exp_label'] = exp_label
    field_dict['meta_label_format'] = label_format
    field_dict['meta_format_file'] = format_file

    if 'meta_date' in field_dict:
        field_dict['meta_date'] = pd.to_datetime(
            field_dict['meta_date'], 'coerce', yearfirst=True)

    return field_dict


def dfun_session_format_name(df_mean, file_field='file_abs_path'):

    file_full_name = df_mean[file_field]
    meta_info = file_meta_info(file_full_name)

    df_mean['file_type'] = meta_info.get('file_type')
    df_mean['meta_exp_label'] = meta_info.get('meta_exp_label')
    df_mean['meta_format_file'] = meta_info.get('meta_format_file')
    df_mean['meta_label_format'] = meta_info.get('meta_label_format')
    df_mean['meta_session'] = meta_info.get('meta_exp_label')
    return df_mean


def dfun_file_meta_info(df_mean, file_field='file_abs_path', flag_label_from_df=True):

    label_column_name = 'meta_label_format'
    # print(df_mean)
    file_full_name = df_mean[file_field]

    if label_column_name in df_mean:
        if type(df_mean[label_column_name]) is not float:
            meta_info = file_meta_info(
                file_full_name, label_format=df_mean[label_column_name])
        else:
            meta_info = file_meta_info(file_full_name)
    else:
        meta_info = file_meta_info(file_full_name)

    df_mean['meta_session'] = meta_info.get('meta_exp_label')

    for key in meta_info:
        # protecting existing key of the df_mean
        if key not in df_mean:
            df_mean[key] = meta_info[key]
    return df_mean


def dfun_update_format_file(df_mean, field=''):

    update_flag = True
    format_file_name = df_mean.name
    # pdb.set_trace()
    # check if need to be rewritten
    with open(format_file_name, 'r') as txt_file:
        format_ = txt_file.readlines(1)[0:2]
        # pdb.set_trace()
        if format_ == [str(df_mean['meta_label_format']) + '\n', str(df_mean['meta_exp_label']) + '\n']:
            update_flag = False

    try:
        if update_flag:
            msg = 'Updating file:{}'.format(format_file_name)
            logger.info(msg)
            with open(format_file_name, 'r+') as txt_file:
                content = txt_file.read()
                txt_file.seek(0)
                edit_str = '*****    Updated on {} *****'.format(
                    pd.datetime.today().date())
                content = str(df_mean['meta_label_format']) + '\n' + \
                    str(df_mean['meta_exp_label']) + '\n' + \
                    edit_str + '\n' + content
                txt_file.write(content)
    except:
        msg = 'Problem updating file: {}'.format(format_file_name)
        logger.warn(msg)
    pass


def dfun_meta_from_field(df_mean, exp_id='meta_exp_label', exp_format='meta_label_format'):

    meta_info = lib_files.get_fields_from_filename(df_mean[exp_id],
                                                   df_mean[exp_format], prefix='meta_', is_file_name=False)
    if 'meta_date' in meta_info:
        meta_info['meta_date'] = pd.to_datetime(
            meta_info['meta_date'], 'coerce', yearfirst=True)

    for key in meta_info:
        # protecting existing key of the df_mean
        if key not in df_mean:
            df_mean[key] = meta_info[key]

    return df_mean

# DATABASE FUNCTIONS -----------------------------------------------------


def df_apply_fun(df_mean, df_fun=None, *args, **kwargs):

    if not df_fun:
        return df_mean

    msg = '    Applying function "{}" to dataframe...'.format(df_fun.__name__)
    logger.info(msg)
    df_mean = df_mean.apply(df_fun, *args, **kwargs)
    msg = '    Done!'
    logger.info(msg)
    return df_mean


def analyses_df_from_rootdir(root_dir=None, dbfun_id=None,
                             dbfun_format=dfun_session_format_name,
                             dbfun_metadata=dfun_file_meta_info,
                             file_filt='*.n[es][v123456]',
                             exclude_files=None):

    if not root_dir:
        return

    # search for all files in rootdir recursively
    msg = '    Searching for files...'
    logger.info(msg)
    files = lib_files.find_files_unix(root_dir, name=file_filt)
    files = map(os.path.abspath, files)

    if exclude_files is not None:
        int_files = filter(lambda x: x in exclude_files, files)
        files = list(set(files) - set(int_files))

    msg = '    found {:d} files to scan'.format(len(files))
    logger.info(msg)

    if len(files) == 0:
        return pd.DataFrame()

    data_df = pd.DataFrame(files, columns=['file_abs_path'])
    # initializing dataframe with the dbfuns
    data_df = df_apply_fun(data_df, dbfun_id, axis=1)
    #data_df = df_apply_fun(data_df, dbfun_format, axis=1)
    data_df = df_apply_fun(data_df, dbfun_metadata, axis=1)

    data_df.sort_index().sort_index(axis=1)
    if'meta_date' in data_df:
        data_df['meta_date'] = pd.to_datetime(data_df['meta_date'])

    return data_df


def save_analysis_df(df_mean, file_path='./dfstore.h5', backup_copies=3):

    hdfstore = pd.HDFStore(file_path)
    if 'df_mean' in hdfstore:
        for i in range(backup_copies)[::-1]:
            curr = 'df_bak_{}'.format(i)
            if i == 0:
                prev = 'df_mean'
            else:
                prev = 'df_bak_{}'.format(i - 1)
            if prev in hdfstore:
                hdfstore[curr] = hdfstore[prev]

    hdfstore['df_mean'] = df_mean
    msg = 'Dataframe saved in:\n{}'.format(os.path.abspath(file_path))
    logger.info(msg)
    hdfstore.close()


def load_analysis_df(file_path='./dfstore.h5'):

    hdfstore = pd.HDFStore(file_path)
    if 'df_mean' in hdfstore:
        df_mean = hdfstore['df_mean']
    else:
        df_mean = pd.DataFrame()
    msg = 'Dataframe loaded from:\n{}'.format(os.path.abspath(file_path))
    logger.info(msg)
    hdfstore.close()
    return df_mean


def run_analysis_on_df_iterator(df_mean, func, key='file_path'):

    # TODO: add filtering
    for row in df_mean.iterrows():
        yield func(row[1][key])


def exp_label_to_csv(root_dir, file_filt='*.n[es][v123456]', save=True):

    if not root_dir:
        return

    # search for all files in rootdir recursively
    msg = '    Searching for files...'
    logger.info(msg)
    files = lib_files.find_files_unix(root_dir, name=file_filt)
    files = map(os.path.abspath, files)

    msg = '    found {:d} files to scan'.format(len(files))
    logger.info(msg)

    if len(files) == 0:
        return pd.DataFrame()

    data_df = pd.DataFrame(files, columns=['file_abs_path'])
    data_df = df_apply_fun(data_df, dfun_session_format_name, axis=1)
    data_df = data_df.groupby('meta_format_file').nth(0)
    data_df.drop('file_abs_path', axis=1, inplace=True)
    if save:
        file_name = 'SESSIONS_FORMAT_LABELS.csv'
        lib_pandas_util.save_df(
            data_df, os.path.join(root_dir, file_name), backup_copies=3)
    return data_df


def update_format_label_from_csv(root_dir, file_filt='*.n[es][v123456]', save=True):

    if not root_dir:
        return

    file_name = 'SESSIONS_FORMAT_LABELS.csv'
    df_mean = lib_pandas_util.load_df(os.path.join(root_dir, file_name))
    # fixing format file
    # pdb.set_trace()
    df_mean.apply(dfun_update_format_file, axis=1)
    return df_mean
