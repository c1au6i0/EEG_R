'''
Created on Sep 15, 2015

@author: scaglionea
'''
import pandas as pd
import os
import pdb  # @UnusedImport
import inspect
import functools
import datetime

from utils import lib_pandas_util as lup
from fileinput import filename

# TODO: change to LOCAL_ANALYSIS_FOLDER_NAME
LOCAL_LOG_FOLDER_NAME = 'LOGS_DB'
ANALYSES_LOG_DF_NAME = 'ANALYSES_LOG_DF.csv'


def prepare_store_path(path='.',
                       file_name=None,
                       local_folder_name=LOCAL_LOG_FOLDER_NAME,
                       ):

    path = os.path.abspath(path)

    if os.path.isfile(path):
        path, _ = os.path.split(path)
    store_path = os.path.join(path, local_folder_name)
    if not os.path.isdir(store_path):
        os.makedirs(store_path)

    if not file_name:
        caller = inspect.currentframe().f_back
        file_name = caller.f_code.co_name

    file_name = os.path.join(store_path, file_name)

    return file_name


def gen_df_path(path='.',
                db_name=ANALYSES_LOG_DF_NAME,
                local_folder_name=LOCAL_LOG_FOLDER_NAME):

    path = os.path.abspath(path)
    file_name = db_name
    path = os.path.join(path, local_folder_name, file_name)
    name, _ = os.path.splitext(path)
    path = name + '.csv'

    return path


def check_analysis(path='.', analysis_label=None, version=None,
                   db_name=ANALYSES_LOG_DF_NAME, local_folder_name=LOCAL_LOG_FOLDER_NAME):

    path = gen_df_path(path=path,
                       db_name=db_name,
                       local_folder_name=local_folder_name)
    # pdb.set_trace()
    if os.path.isfile(path):
        df_mean = pd.DataFrame.from_csv(path)
    else:
        return None

    if analysis_label in df_mean.index:
        if version is not None:
            # pdb.set_trace()
            if df_mean.loc[analysis_label, 'version'] == version.__repr__():
                return df_mean.loc[analysis_label, 'data_file']
            else:
                return
        return df_mean.loc[analysis_label, 'data_file']
    return None


def get_df_entry(path='.', file_name=ANALYSES_LOG_DF_NAME, index=None,
                 version=None, value='data_file'):
    # TODO: instead of using `version` we can pass a dictionary with the
    # key,values to test
    path = os.path.join(path, file_name)

    # pdb.set_trace()
    if os.path.isfile(path):
        df_mean = pd.DataFrame.from_csv(path)
    else:
        return

    # checking the index
    if index not in df_mean.index:
        return

    # checking the value
    if value not in df_mean:
        return

    # return based on version
    if version is not None:
        if df_mean.loc[index, 'version'] == version.__repr__():
            return df_mean.loc[index, value]

    if version is None:
        return df_mean.loc[index, value]

    return None


def log_entry(filename=None, dict_like=None, index=None):

    if filename is None:
        raise Exception('No filename provided')

    filename = os.path.abspath(filename)
    path = os.path.dirname(filename)

    if not os.path.isdir(path):
        os.makedirs(path)

    df_mean = pd.DataFrame(dict_like)
    if index is not None:
        df_mean = df_mean.set_index(index)

    if os.path.isfile(filename):
        ex_db = lup.load_df(filename)
        df_mean = lup.combine_df(df_mean, ex_db, how='left_not_null')

    lup.save_df(df_mean, filename)


def log_current_analysis(file_name=None, root_dir=None, caller_name=None, caller_name_suffix=None):

    if not caller_name:
        # get the caller namespace in case none is provided
        caller = inspect.currentframe().f_back
        caller_name = caller.f_code.co_name
        version = caller.f_locals.get('__version__', None)
    if caller_name_suffix:
        caller_name = caller_name + '-' + caller_name_suffix

    if not file_name:
        file_name = ANALYSES_LOG_DF_NAME
    else:
        name, _ = os.path.splitext(file_name)
        file_name = '_'.join([name, ANALYSES_LOG_DF_NAME])

    if not root_dir:
        root_dir = os.path.curdir

    abs_file_name = os.path.join(root_dir, file_name)

    dfa = dict()
    #dfa['Analysis'] = caller_name
    dfa['Date'] = pd.datetime.today()
    dfa['Version'] = version
    dfa['Performed'] = 'True'
    dfn = pd.DataFrame(dfa, index=[caller_name])
    dfn.index.name = 'Analysis'

    if os.path.isfile(abs_file_name):
        df_mean = pd.DataFrame.from_csv(abs_file_name)
        if caller_name in df_mean.index:
            df_mean.loc[caller_name] = dfn.loc[caller_name]
        else:
            df_mean = df_mean.append(dfn)
    else:
        df_mean = dfn

    df_mean.to_csv(abs_file_name)
    return df_mean


# SAVE AND LOAD ANALYSES -----------------------------------------------------


def load_analysis(path='.',
                  file_name=None,
                  local_folder_name=LOCAL_LOG_FOLDER_NAME):

    path = os.path.abspath(path)

    if file_name is not None:
        if os.path.isfile(os.path.join(path, file_name)):
            return lup.load_df(file_name)

    if os.path.isfile(path):
        path, _ = os.path.split(path)
    save_path = os.path.join(path, local_folder_name)

    if not os.path.isdir(save_path):
        return

    if file_name is None:
        caller = inspect.currentframe().f_back
        analysis_label = caller.f_code.co_name
        file_name = os.path.join(save_path, analysis_label)

    pdb.set_trace()

    return lup.load_df(file_name)

# DECORATORS -------------------------------------------------------------


def log_analysis_to_df(path='.',
                       file_name=ANALYSES_LOG_DF_NAME,
                       local_folder_name=LOCAL_LOG_FOLDER_NAME,
                       store_type='csv',
                       overwrite=False):

    def log_analysis_db_decorator(func):

        @functools.wraps(func)
        def wrapper(*args, **kws):

            # TODO: implement check
            # checking if analysis has been already performed and an output has
            # been saved otherwise we run again the analysis
            try:
                output = func(*args, **kws)
                run_status = True
                run_log = 'Completed'
            except Exception as ex:
                run_status = False
                output = 'ERROR RUNNING {}'.format(func.__name__)
                run_log = 'ERROR RUNNING {} : {}'.format(func.__name__, ex)

            file_name_analysis_df = gen_df_path(
                path, db_name=file_name,
                local_folder_name=local_folder_name)
            version = getattr(func, '__version__', None)

            data_dict = {'ID': [func.__name__],
                         'version': [version],
                         'date': [pd.datetime.today()],
                         'run_status': [run_status],
                         'run_log': [run_log],
                         }
            log_entry(file_name_analysis_df, data_dict, index='ID')

            return output

        return wrapper

    return log_analysis_db_decorator
