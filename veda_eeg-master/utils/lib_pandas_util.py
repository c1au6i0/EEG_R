'''
Created on May 18, 2016

@author: scaglionea
'''

import functools
import os

import pandas as pd
from utils import lib_logger
import pdb

logger = lib_logger.create_logger()


def load_df(filename, h5_db_name='df_mean'):

    _, ext = os.path.splitext(filename)
    ex_db = pd.DataFrame()

    if os.path.isfile(filename):
        if ext == '.csv':
            ex_db = pd.DataFrame.from_csv(filename)
        if ext == '.h5':
            store = pd.HDFStore(filename)

            with store as store:
                ex_db = store[h5_db_name]
                store.close()

    return ex_db


def save_df(df_mean, filename, h5_db_name='df_mean', backup_copies=0):

    path = os.path.dirname(filename)
    if not os.path.isdir(path):
        os.makedirs(path)

    filename_ne, ext = os.path.splitext(filename)

#     if os.path.isfile(filename):
#         if ext == '.csv':
#             ex_db = pd.DataFrame.from_csv(filename)
#         if ext == '.h5':
#             store = pd.HDFStore(filename)
#
#             with store as store:
#                 ex_db = store[h5_db_name]

    if backup_copies > 0:
        if ext == '.csv':
            for i in range(backup_copies)[::-1]:
                tmp = filename_ne + '_bak_{}.csv'.format(i)
                if i == 0:
                    prev = filename
                else:
                    prev = filename_ne + '_bak_{}.csv'.format(i - 1)

                if os.path.isfile(prev):
                    pd.DataFrame.from_csv(prev).to_csv(tmp)

        if ext == 'h5':
            store = pd.HDFStore(filename)
            with store:
                for i in range(backup_copies)[::-1]:
                    curr = 'df_bak_{}'.format(i)
                    if i == 0:
                        prev = 'df_mean'
                    else:
                        prev = 'df_bak_{}'.format(i - 1)
                    if prev in store:
                        store[curr] = store[prev]

    if ext == '.csv':
        df_mean.to_csv(filename)
    if ext == '.h5':
        store = pd.HDFStore(filename)

        with store as store:
            store[h5_db_name] = df_mean


def combine_df(left_df, right_df, on=None, how='left', droplr=True):
    '''
    combine two dfs on the given key, if key is not given on the index of the
    dfs. The parameter how defines the method used for combining the two dfs:

    -'left': keeps all values from original df_mean, if a duplicate based on the key is
    found in the right_df the change is discarded

    -'left_not_null': keeps all values from original df_mean if they are not null, if
    a duplicate based on the key is found in the right_df only null values in each
    key are updated

    -'right':

    -'right_not_null':

    -'suffix':

    :param left_df:
    :param right_df:
    :param key:
    :param how:
    '''

    r_suffix = '__right__'
    l_suffix = '__left__'
    suffixes = (l_suffix, r_suffix)

    if left_df.size == 0:
        return right_df

    if right_df.size == 0:
        return left_df

    if on is None:

        if how == 'suffix':
            return left_df.merge(
                right_df, how='outer', left_index=True, right_index=True)
        out_df = left_df.merge(
            right_df, how='outer', left_index=True, right_index=True,
            suffixes=suffixes)

    else:
        out_df = left_df.merge(
            right_df, how='outer', on=on, suffixes=suffixes)

    for key in out_df:
        if key[-len(r_suffix):] == r_suffix:
            col = key[:-9]
            l_col = col + l_suffix
            r_col = col + r_suffix
            op_col = col + '__data_origin__'

            # fixing date issues
            if type(out_df[l_col][0]) in [pd.tslib.Timestamp, pd.tslib.NaTType]:
                out_df[r_col] = pd.to_datetime(out_df[r_col])

            if type(out_df[r_col][0]) in [pd.tslib.Timestamp, pd.tslib.NaTType]:
                out_df[l_col] = pd.to_datetime(out_df[l_col])

            if how[:4] == 'left':
                out_df[col] = out_df[l_col]
                out_df[op_col] = 'left'

            if how[:5] == 'right':
                out_df[col] = out_df[r_col]
                out_df[op_col] = 'right'

            if how == 'left_not_null':
                nulls = out_df[col].isnull()
                out_df.loc[nulls, col] = out_df[r_col][nulls]
                out_df.loc[nulls, op_col] = 'right'

            if how == 'right_not_null':
                nulls = out_df[col].isnull()
                out_df.loc[nulls, col] = out_df[l_col][nulls]
                out_df.loc[nulls, op_col] = 'left'

            if droplr:
                out_df.drop(r_col, axis=1, inplace=True)
                out_df.drop(l_col, axis=1, inplace=True)
                out_df.drop(op_col, axis=1, inplace=True)

    return out_df.sort_index(axis=1)

# DF FUNCTIONS -----------------------------------------------------------


def zscore(df_mean):

    return (df_mean - df_mean.mean()) / df_mean.std()


# DECORATORS -------------------------------------------------------------


def save_df_decorator(path=None, file_name='temp_df.csv',
                      h5_db_name='df_mean', backup_copies=0):
    '''
    save the dataframe returned by the decorated function at the location given
    by path and file_name. If path is None then makes the location relative to
    the first arg of the decorated function if not then to the current location.

    :param path:
    :param file_name:
    :param h5_db_name:
    :param backup_copies:
    '''

    def decorator(func):

        @functools.wraps(func)
        def wrapper(*args, **kws):

            output = func(*args, **kws)

            if path is None:
                root = args[0]
                try:
                    if not os.path.isdir(root):
                        root = '.'
                except:
                    root = '.'

            root, basename = os.path.split(os.path.join(root, file_name))

            if not os.path.isdir(root):
                os.makedirs(root)

            # saving now
            save_df(
                output, os.path.join(root, basename),
                h5_db_name, backup_copies)

            return output

        return wrapper

    return decorator
