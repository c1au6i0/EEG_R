#!/usr/bin/env python
'''
Created on Mar 26, 2016-test linked resource

@author: scaglionea
'''

import pdb  # @UnusedImport
# import functools
# import sys
import os

#import lib_files
import lib_data_df
from utils import lib_pandas_util
import lib_analysis_store
from lib_fun import set_fun_ver

# LOGGER -----------------------------------------------------------------
from lib_logger import create_logger, log_execution
logger = create_logger()

# CONSTANTS --------------------------------------------------------------
LOCAL_ANALYSIS_FOLDER = './ANALYSES'
LOCAL_DF_FOLDER = os.path.join(LOCAL_ANALYSIS_FOLDER, 'DFs')

RAW_DATA_DF_NAME = 'RAWDATA_df.h5'
SESSION_DF_NAME = 'SESSION_df.h5'


@log_execution(logger=logger)
@set_fun_ver()
def create_raw_file_df(root_dir):

    #raw_datadb_path = os.path.join(global_pandas_dir, RAW_DATA_DF_NAME)
    #session_datadb_path = os.path.join(global_pandas_dir, SESSION_DF_NAME)
    df_mean = lib_data_df.analyses_df_from_rootdir(root_dir)
    return df_mean


@log_execution(logger=logger)
@set_fun_ver()
def create_session_df(root_dir, session_field='meta_session'):

    df_mean = create_raw_file_df(root_dir)

    if df_mean.size == 0:
        return df_mean

    if session_field not in df_mean:
        logger.warn('`{}` not in df_mean'.format(session_field))
        return df_mean

    session_df = df_mean.set_index(session_field)
    session_df = session_df[~session_df.index.duplicated()]
    session_df = session_df.reset_index()
    return session_df


@lib_pandas_util.save_df_decorator(path=None, file_name=os.path.join(LOCAL_DF_FOLDER, RAW_DATA_DF_NAME), backup_copies=3)
def create_raw_file_df_save(root_dir):
    return create_raw_file_df(root_dir)


@lib_pandas_util.save_df_decorator(path=None, file_name=os.path.join(LOCAL_DF_FOLDER, SESSION_DF_NAME), backup_copies=3)
@log_execution(logger=logger)
@set_fun_ver()
def create_session_df_save(root_dir):
    return create_session_df(root_dir)


def load_raw_file_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=RAW_DATA_DF_NAME):

    df_file_name = os.path.join(root_dir, local_folder, df_name)
    df_mean = lib_pandas_util.load_df(df_file_name)
    return df_mean


def load_session_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=SESSION_DF_NAME):

    df_file_name = os.path.join(root_dir, local_folder, df_name)
    df_mean = lib_pandas_util.load_df(df_file_name)
    return df_mean


@log_execution(logger=logger)
@set_fun_ver()
def update_raw_file_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=RAW_DATA_DF_NAME):

    df_file_name = os.path.join(root_dir, local_folder, df_name)
    logger.debug(df_file_name)
    if os.path.isfile(df_file_name):
        df_mean = lib_pandas_util.load_df(df_file_name)
    else:
        return create_raw_file_df(root_dir)

    # getting df_mean only of new files:
    df_add = lib_data_df.analyses_df_from_rootdir(
        root_dir, exclude_files=df_mean['file_abs_path'].tolist())

    if df_mean.add == 0:
        return df_mean

    return lib_pandas_util.combine_df(df_mean, df_add, on=['file_abs_path'], how='right')


@log_execution(logger=logger)
@set_fun_ver()
def update_session_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=SESSION_DF_NAME, session_field='meta_session'):

    df_mean = update_raw_file_df(
        root_dir, local_folder=LOCAL_DF_FOLDER, df_name=RAW_DATA_DF_NAME)

    session_df = df_mean.set_index(session_field)
    session_df = session_df[~session_df.index.duplicated()]
    session_df = session_df.reset_index()

    return session_df


@lib_pandas_util.save_df_decorator(path=None, file_name=os.path.join(LOCAL_DF_FOLDER, RAW_DATA_DF_NAME), backup_copies=3)
@log_execution(logger=logger)
@set_fun_ver()
def update_raw_file_df_save(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=RAW_DATA_DF_NAME):
    return update_raw_file_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=RAW_DATA_DF_NAME)


@lib_pandas_util.save_df_decorator(path=None, file_name=os.path.join(LOCAL_DF_FOLDER, SESSION_DF_NAME), backup_copies=3)
@log_execution(logger=logger)
@set_fun_ver()
def update_session_df_save(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=SESSION_DF_NAME):
    return update_session_df(root_dir, local_folder=LOCAL_DF_FOLDER, df_name=SESSION_DF_NAME)


@log_execution(logger=logger)
@set_fun_ver()
def search_analyses(df_or_path, by='session', on=['meta_session']):
    '''
    Aggregates analysis based by session_df or raw_files_df basis. 

    :param df_mean: could be a DataFrame or path to existing file or directory
    :param by:
    :param analysis_label:
    '''

    if type(df_or_path) is lib_data_df.pd.DataFrame:
        df_mean = df_or_path

    elif os.path.isfile(df_or_path):
        df_mean = lib_pandas_util.load_df(df_or_path)

    elif os.path.isdir(df_or_path):

        if 'session' in by:
            df_name = SESSION_DF_NAME

        elif 'raw_file' in by:
            df_name = RAW_DATA_DF_NAME
            on = on + ['file_abs_path']

        try:
            df_mean = load_session_df(
                df_or_path, local_folder=LOCAL_DF_FOLDER, df_name=df_name)
        except:
            if 'session' in by:
                df_mean = create_session_df(df_or_path, on)
            elif 'raw_file' in by:
                df_mean = create_raw_file_df(df_or_path)
                on = on + ['file_abs_path']

    out_df = lib_data_df.pd.DataFrame()
    for row in df_mean.iterrows():
        analysis_df_path = os.path.join(row[1]['file_path'],
                                        lib_analysis_store.LOCAL_LOG_FOLDER_NAME,
                                        lib_analysis_store.ANALYSES_LOG_DF_NAME)
        if os.path.isfile(analysis_df_path):
            try:
                df_analysis = lib_pandas_util.load_df(analysis_df_path)
            except:
                logger.warn('Problem opening: {}'.format(analysis_df_path))
                df_analysis = lib_data_df.pd.DataFrame()
        else:
            df_analysis = lib_data_df.pd.DataFrame()
        df_analysis['file_path'] = row[1]['file_path']
        df_analysis['an_df_folder_path'], _ = os.path.split(analysis_df_path)
        for key in on:
            df_analysis[key] = row[1][key]

        out_df = out_df.append(df_analysis)

    out_df.index.name = 'analysis_label'
    out_df.reset_index(inplace=True)

    # pdb.set_trace()

    out = lib_pandas_util.combine_df(df_mean, out_df, on=on + ['file_path'])
    return out[~out['data_file'].isnull()]


@log_execution(logger=logger)
@set_fun_ver()
def aggregate_analysis(df_or_path, by='session', on=['meta_session'], analysis_label=['eeg_opto_analysis', 'lfp_opto_analysis']):
    '''
    Aggregates analysis based by session_df or raw_files_df basis. 

    :param df_mean: could be a DataFrame or path to existing file or directory
    :param by:
    :param analysis_label:
    '''
    
    if type(df_or_path) is lib_pandas_util.pd.DataFrame:
        an_df = df_or_path
    else:
        an_df = search_analyses(df_or_path, by=by, on=on)
        
    out_df = lib_data_df.pd.DataFrame()
    for _, row in an_df.iterrows():
        data_file = os.path.join(row['an_df_folder_path'], row['data_file'])

        if os.path.isfile(data_file):
            df_mean = lib_pandas_util.load_df(data_file)
            for key in row.index:
                # pdb.set_trace()
                df_mean[key] = row[key]
            out_df = out_df.append(df_mean)

    return out_df
