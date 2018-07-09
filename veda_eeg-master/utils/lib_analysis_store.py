'''
Created on Mar 26, 2016-test linked resource

@author: scaglionea
'''

import pdb  # @UnusedImport
import functools
#import sys
import os
import inspect

from utils import lib_analysis_log as lib_an_log
from utils.lib_analysis_log import LOCAL_LOG_FOLDER_NAME, ANALYSES_LOG_DF_NAME
from utils import lib_pandas_util as lup
from lib_fun import set_fun_ver

LOCAL_ANALYSES_FOLDER_NAME = 'ANALYSES_STORE'


# LOGGER -----------------------------------------------------------------
from utils.lib_logger import create_logger
logger = create_logger()


@set_fun_ver((0, 9, 1))
def save_analysis(df_mean=None, path='.',
                  file_name=None, analysis_label=None, auto_path=True,
                  type_='pandas.HDFStore', df_path=None):

    if df_mean is None:
        raise Exception('nothing to save')

    # get the caller namespace in case none is provided
    if analysis_label is None:
        caller = inspect.currentframe().f_back
        analysis_label = caller.f_code.co_name

    if auto_path and file_name is None:
        save_path = os.path.join(path, LOCAL_ANALYSES_FOLDER_NAME)
    else:
        save_path = path
    if not os.path.isdir(save_path):
        os.makedirs(save_path)

    if not file_name:
        file_name = analysis_label

    file_name = os.path.join(save_path, file_name)
    # pdb.set_trace()
    if type_ == 'pandas.HDFStore':

        file_name = file_name + '.h5'
        lup.save_df(df_mean, file_name)

    if df_path is None:
        df_path = os.path.join(save_path, ANALYSES_LOG_DF_NAME)

    # saves the analysis df_log
    data_file = os.path.relpath(
        file_name, os.path.split(df_path)[0])
    data_dict = {'ID': [analysis_label],
                 'data_file': [data_file],
                 'type': [type_],
                 'shape': [df_mean.shape]
                 }
    lib_an_log.log_entry(
        df_path, data_dict, index='ID')

    lib_an_log.log_entry(df_path, data_dict, index='ID')

# DECORATORS -------------------------------------------------------------
# decorator that stores the results of an analysis. Stores only the output
# returned from the function.


def store_output(path='.',
                 file_name=None,
                 analyses_log_df_name=ANALYSES_LOG_DF_NAME,
                 local_log_folder_name=LOCAL_LOG_FOLDER_NAME,
                 local_analyses_folder_name=LOCAL_ANALYSES_FOLDER_NAME,
                 store_type='h5',
                 overwrite=False):

    def store_output_decorator(func):

        # prepping operations
        if file_name is None:
            file_name_ = func.__name__

        store_file_name = lib_an_log.prepare_store_path(
            path=path, file_name=file_name_,
            local_folder_name=local_analyses_folder_name,)

        @functools.wraps(func)
        def wrapper(*args, **kws):
            __save_analysis_version__ = (0, 9, 0)

            # checking if analysis has been already performed and an output has
            # been saved otherwise we run again the analysis
            # pdb.set_trace()
            df_path = lib_an_log.gen_df_path(path=path, db_name=analyses_log_df_name,
                                             local_folder_name=LOCAL_LOG_FOLDER_NAME)

            data_file = lib_an_log.get_df_entry(
                *os.path.split(df_path),
                version=getattr(func, '__version__', None),
                value='data_file')

            #pdb.set_trace()
            if __save_analysis_version__ != save_analysis.__version__:
                overwrite = True

            if data_file is not None and not overwrite:
                data_file = os.path.join(os.path.split(df_path)[0], data_file)
                output = lib_an_log.load_analysis(*os.path.split(data_file))
                if output:
                    return output

            # the output is not available recalculating function
            try:
                output = func(*args, **kws)
            except:
                output = None

            # here is where we store the output of the function
            # pdb.set_trace()
            if output is not None:
                save_analysis(
                    output, *os.path.split(store_file_name),
                    analysis_label=func.__name__, df_path=df_path)

            return output

        return wrapper

    return store_output_decorator

# decorator that stores the results of an analysis. Stores only the output
# returned from the function.
