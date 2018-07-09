'''
Created on Aug 23, 2016

@author: scaglionea
'''
import os

import numpy as np
#import scipy as sp
import scipy.signal as spsi

import pandas as pd
import pdb
from veda_eeg.utils import lib_files, lib_logger

logger = lib_logger.create_logger()

spectrogram = spsi.spectrogram
welch = spsi.welch


def sub_sample(df_mean, sub_index='Frequency', edges=[4, 8, 13, 30, 50], return_type='df_mean', band_names=None):

    band_names = None
    if band_names is None:
        if sub_index == 'Frequency':
            if edges == [4, 8, 13, 30, 50]:
                band_names = [r'$\delta$', r'$\theta$', r'$\alpha$',
                              r'$\beta$', r'$\gamma$']

    index_dict = dict(zip(df_mean.index.names, [None for _ in df_mean.index.names]))

    for index in df_mean.index.names:
        index_dict[index] = df_mean.index.get_level_values(index).unique()

    size_list = [index_dict[item].size for item in df_mean.index.names]

    sp_mat = df_mean['PSD'].values.reshape(*size_list)

    axes = np.roll(
        np.arange(len(df_mean.index.names)), -1 * df_mean.index.names.index(sub_index))
    # np.argsort(axes) is the inverse function
    sp_mat = sp_mat.transpose(axes)

    sp_mat = sp_mat[index_dict[sub_index] <= max(edges), :, :]
    # pdb.set_trace()
    index_dict[sub_index] = index_dict[sub_index][
        index_dict[sub_index] <= max(edges)]
    sub_array = np.digitize(index_dict[sub_index], edges, right=True)

    sp_mat = np.stack([np.nanmean(sp_mat[sub_array == index, :, :], 0)
                       for index in np.unique(sub_array)], 0)

    index_dict[sub_index] = np.array(
        [index_dict[sub_index][sub_array == index].values.mean(0) for index in np.unique(sub_array)])
    sp_mat = sp_mat.transpose(np.argsort(axes))

    if return_type is not 'df_mean':
        return index_dict, sp_mat

    if band_names is not None:
        index_dict[sub_index] = band_names

    df_index = pd.MultiIndex.from_product(
        [index_dict[sub_index] for sub_index in df_mean.index.names], names=df_mean.index.names)

    df_mean = pd.DataFrame(data=sp_mat.flatten(), index=df_index, columns=['PSD'])
    df_mean.sort_index(inplace=True)

    return df_mean


def dB(x, out=None):
    '''
    Converts the given vector in decibels

    :param x:
    :type x:
    :param out:
    :type out:
    '''

    if out is None:
        return 10 * np.log10(x)
    else:
        np.log10(x, out)
        np.multiply(out, 10, out)


def spectra_analysis(session_data, parameters=None, *args, **kws):
    '''

    :param session_data:
    :type session_data:
    :param parameters:
    :type parameters:
    :return a tuple containg (freq, time_lags, sp_db)
    '''

    if parameters is None:
        parameters = dict()

    if 'psd_units' not in parameters:
        psd_units = 'db'
    else:
        psd_units = parameters['psd_units']

    if 'fs' not in parameters:
        parameters['fs'] = session_data['voltage_header'][
            0]['sampling_freq']

    if 'available_channels' not in parameters:
        available_channels = range(
            session_data['voltage_series'].shape[0])
    else:
        available_channels = parameters['available_channels']
        if isinstance(available_channels, str) or isinstance(available_channels, unicode):
            available_channels = eval(available_channels)
        parameters['available_channels'] = available_channels

    if 'chan_names' in parameters:
        chan_ids = available_channels
        if isinstance(chan_ids, str) or isinstance(chan_ids, unicode):
            chan_ids = eval(chan_ids)
        chan_names = parameters['chan_names']
        if isinstance(chan_names, str) or isinstance(chan_names, unicode):
            chan_names = eval(chan_names)
        parameters['chan_ids'] = chan_ids
        parameters['chan_names'] = chan_names

        for chan_id, name in zip(chan_ids, chan_names):
            session_data['voltage_header'][chan_id]['name'] = name

    sampling_freq = parameters.get('fs', 1)
    window_size = parameters.get('window_size', 10)

    freqs, time_lags, sp = list(spectrogram(session_data['voltage_series'][available_channels, :],
                                            fs=sampling_freq,
                                            nperseg=window_size *
                                            int(sampling_freq),
                                            noverlap=0, window='hann',
                                            detrend='constant',
                                            *args, **kws))

    if psd_units is 'db':
        sp = dB(sp)

    return freqs, time_lags, sp


def spectra_analysis_df(session_data, parameters=None,
                        *args, **kws):

    if 'save_results' in parameters:
        save_results = parameters['save_results']
    else:
        save_results = True

    if 'add_acc' in parameters:
        add_acc = parameters['add_acc']
    else:
        add_acc = True

    if 'return_results' in parameters:
        return_results = parameters['return_results']
    else:
        return_results = True

    if 'session_path' not in parameters:
        parameters['session_path'] = session_data['meta_data']['session_path']

    freqs, time_lags, sp = spectra_analysis(session_data=session_data,
                                            parameters=parameters,
                                            *args, **kws)

    if 'max_fr' not in parameters:
        parameters['max_fr'] = 60

    max_fr = parameters['max_fr']

    # considering only frequencies up to 60Hz
    fr_red = freqs[0:sum(freqs <= max_fr)]
    fr_step = 0.5
    parameters['fr_step'] = fr_step
    intervals = np.arange(0, max_fr + fr_step, fr_step)
    index_array = np.digitize(fr_red, intervals)

    if fr_red.size > 120:
        # reducing the frequencies to fr_step hz
        fr_red = freqs[0:sum(freqs < max_fr + fr_step)]
        intervals = np.arange(0, max_fr + fr_step, fr_step)
        index_array = np.digitize(freqs, intervals)

        sp = np.stack([sp[:, index_array == index, :].mean(1)
                       for index in np.unique(index_array)][:-1], 1)
        fr_red = freqs = intervals[:-1]

    if 'chan_names' in parameters:
        chan_names = parameters['chan_names']
    else:
        chan_names = [chan['name'] for chan in session_data['voltage_header']]

    index = pd.MultiIndex.from_product(
        [chan_names, fr_red, time_lags],
        names=['Channel', 'Frequency', 'Time'])

    df_mean = pd.DataFrame(
        data=sp[:, 0:sum(freqs <= 60), :].flatten(),
        index=index, columns=['PSD'])

    df_mean.sort_index(inplace=True)

    # adding meta_data information
    if 'meta_data' in session_data:
        add_meta_info_to_df(df_mean, parameters)

    # adding accelerometer information
    if add_acc:
        # adding the modulus of the force recorded on the three axis
        df_acc = accelerometer_module_df(session_data=session_data,

                                         time_lags=time_lags,
                                         parameters=parameters)
        if save_results:
            file_name = os.path.join(
                parameters['session_path'], 'ACC.csv.gz')
            df_acc.to_csv(file_name, compression='gzip')

    if save_results:
        file_name = os.path.join(parameters['session_path'], 'PSD.csv.gz')
        df_mean.to_csv(file_name, compression='gzip')

    if not return_results:
        return

    if add_acc:
        return df_mean, df_acc
    return df_mean


def accelerometer_module(session_data, time_lags, parameters=None):

    if parameters is None:
        parameters = dict()

    window_size = parameters.get('window_size', 10)

    def module(matr):
        return (np.sqrt((matr ** 2).sum(0))).mean()

    acc_fs = session_data['aux_header'][0]['sampling_freq']

    bounds = np.vstack(((time_lags - window_size / 2) * acc_fs,
                        (time_lags + window_size / 2) * acc_fs)).astype(int).T

    gen = (session_data['aux_series'][:, slice(*bound)]
           for bound in bounds)
    # pdb.set_trace()
    mod_series = map(module, gen)

    return np.asarray(mod_series)


def accelerometer_module_df(session_data, time_lags, parameters=None):

    mod_series = accelerometer_module(session_data=session_data,
                                      time_lags=time_lags,
                                      parameters=parameters)
    df_acc = pd.DataFrame(
        data=mod_series, index=time_lags, columns=['mean_acc_modulus'])
    df_acc.index.name = 'Time'
    df_acc['Acc_x'] = session_data['aux_series'][
        0, time_lags.astype(np.int) * int(session_data['aux_header'][0]['sampling_freq'])]
    df_acc['Acc_y'] = session_data['aux_series'][
        1, time_lags.astype(np.int) * int(session_data['aux_header'][1]['sampling_freq'])]
    df_acc['Acc_z'] = session_data['aux_series'][
        2, time_lags.astype(np.int) * int(session_data['aux_header'][2]['sampling_freq'])]
    df_acc['inst_acc_modulus'] = np.sqrt(
        df_acc['Acc_x']**2 + df_acc['Acc_y']**2 + df_acc['Acc_z']**2)

    if 'meta_data' in session_data:
        add_meta_info_to_df(df_acc, parameters)

    return df_acc


def add_meta_info_to_df(df_mean=None, field_dict=dict()):

    for field in field_dict:
        if np.size(field_dict[field]) == 1:
            df_mean.loc[:, field] = field_dict[field]
