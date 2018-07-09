'''
Created on Aug 23, 2016

@author: scaglionea
'''
import os
# standard
import numpy as np
# pip installables
from matplotlib import pyplot

from mpl_toolkits.axes_grid1 import make_axes_locatable  # @UnresolvedImport

import pprint
from cycler import cycler

# veda eeg internals
import spectral as sp
from veda_eeg.utils import lib_files, lib_logger
from veda_eeg.analysis.dose_funs import inj_num, dosages, inj_times
import pdb
from veda_eeg.analysis.spectral import sub_sample
logger = lib_logger.create_logger()


def plot_spectrogram_df(df_psd, parameters=None, * args, **kws):
    '''
    Plots the spectrogram of the given veda_eeg `session_data`

    :param session_data: the data arranged in the veda format
    :type session_data: data
    :param parameters: A dictionary containing all paramters for spectral analysis
    :type parameters: dict

    Example of parameters dictionary

    {'avaliable_channels': [1, 2, 3, 4, 5, 6],
     'baseline': '10',
     'd0': '20',
     'experiment': 'Single',
     'timeinterval': '10'}
    '''

    normalizations = ['baseline', 'power']

    if 'baseline' not in parameters:
        raise Exception('No baseline parameter given, nothing to do')

    if 'normalization' not in parameters:
        parameters['normalization'] = ''

    if 'save_ext' not in parameters:
        parameters['save_ext'] = '.pdf'

    save_ext = parameters['save_ext']
    baseline = float(parameters['baseline'])
    time_interval = float(parameters.get('timeinterval', 10))
    experiment = parameters['experiment']

    msg = '''Parameters: {}'''.format(pprint.pformat(parameters))
    print(msg)

    if experiment.upper() == 'SINGLE':
        d0 = 1
        d1 = 32
        dose_interval = 0.5

    fig_list = []

    map_fig, axs = pyplot.subplots(
        3, 2, sharex=True, sharey=True, figsize=(11, 17))

    lags = df_psd.index.get_level_values('Time').unique()
    freqs = df_psd.index.get_level_values('Frequency').unique()

    df_psd_bands = sub_sample(df_psd)

    for chan in df_psd.index.get_level_values('Channel').unique():
        fig = pyplot.figure(figsize=(11, 8.5))
        ax_0 = pyplot.subplot(2, 2, 1)
        cmap = pyplot.get_cmap('viridis')

        sp_db = df_psd.loc[chan][
            'PSD'].values.reshape(freqs.size, lags.size)
        im = pyplot.imshow(sp_db,
                           cmap=cmap,
                           # aspect=scale,
                           origin='lower',
                           extent=[min(lags) / 60, max(lags) / 60, min(freqs), max(freqs)], interpolation='none')

        pyplot.xlabel('Time (min)')
        pyplot.ylabel('Frequency (Hz)')
        #divider = make_axes_locatable(ax_0)
        #cax = divider.append_axes("top", size="5%", pad=0.05)
        pyplot.colorbar(im)

        ax_1 = pyplot.subplot(2, 2, 2)

        legend = []
        chan_name = chan
        pyplot.title('chan_name: {}'.format(chan_name))
        cm = pyplot.get_cmap('viridis')(1. /
                                        np.arange((lags.max() / 60. - baseline) / time_interval + 1))

        ax_1.set_prop_cycle(cycler('color', cm))

        if chan_name.upper()[-2:] == 'FL':
            map_ax = axs[0, 0]

        elif chan_name.upper()[-2:] == 'FR':
            map_ax = axs[0, 1]

        elif chan_name.upper()[-2:] == 'PL':
            map_ax = axs[1, 0]

        elif chan_name.upper()[-2:] == 'PR':
            map_ax = axs[1, 1]

        elif chan_name.upper()[-2:] == 'OL':
            map_ax = axs[2, 0]

        elif chan_name.upper()[-2:] == 'OR':
            map_ax = axs[2, 1]

        else:
            map_ax = None

        if map_ax is not None:
            map_ax.set_prop_cycle(cycler('color', cm))

        intervals = np.arange(
            (lags.max() / 60. - baseline) / time_interval) * time_interval + baseline
        index_array = np.digitize(lags, intervals * 60)
        for i in np.unique(index_array):
            # pdb.set_trace()
            pl_spect = np.nanmean(
                sp_db[:, index_array == i], 1)

            if parameters['normalization'] is 'baseline':
                pl_spect = (pl_spect) / \
                    np.nanmean(sp_db[:, index_array == 0])

            if parameters['normalization'] is 'power':
                pl_spect = (pl_spect) / \
                    np.nanmean(sp_db[:, index_array == i])

            pyplot.plot(freqs, pl_spect)
            legend.append(
                '{:2.0f} min'.format(np.nanmean(lags[index_array == i] / 60)))
            if map_ax is not None:
                map_ax.plot(freqs, pl_spect)

        map_ax.legend(legend)
        psd_units = 'PSD (db)'
        if 'psd_units' in parameters:
            if parameters['psd_units'] is not 'db':
                psd_units = 'PSD (uV^2/Hz)'

        if parameters['normalization'] is not '':
            psd_units = 'PSD (%)'

        map_ax.set_ylabel(psd_units)
        map_ax.set_xlabel('Frequency (Hz)')
        map_ax.set_title('Chan:{}'.format(chan_name))

        pyplot.legend(legend)
        # pyplot.xlim((0,20))
        pyplot.xlabel('Frequency (Hz)')
        pyplot.ylabel(psd_units)

        ax_2 = pyplot.subplot(223, sharex=ax_0)
        ax_2.set_prop_cycle(cycler('color', cm))
        df_psd_bands_red = df_psd_bands.loc[chan]
        legend = []
        for bands in df_psd_bands_red.index.get_level_values('Frequency').unique():
            norm = 1
            if parameters['normalization'] is 'baseline':
                norm = (sp_db[:, index_array == 0])

            if parameters['normalization'] is 'power':
                norm = np.nanmean(sp_db[:, :], 0)

            pyplot.plot(lags / 60, df_psd_bands_red.loc[bands]['PSD'] / norm)
            legend.append(bands)
        pyplot.legend(legend)
        pyplot.xlabel('Time (min)')
        pyplot.ylabel(psd_units)

        # equalizing axes
        fig.tight_layout()
        pyplot.draw()
        ax_list = fig.get_axes()

        ax_0_pos = ax_list[0].get_position()

        ax_1_pos = ax_1.get_position()
        ax_2_pos = ax_2.get_position()

        # pdb.set_trace()
        ax_1.set_position(
            [ax_1_pos.x0, ax_0_pos.y0, ax_0_pos.width, ax_0_pos.height])
        ax_2.set_position(
            [ax_0_pos.x0, ax_2_pos.y0, ax_0_pos.width, ax_0_pos.height])

        fig_list.append(fig)

        if True:
            # saving individual channels
            file_name = os.path.join(parameters['session_path'], chan_name)
            if parameters['normalization'] in normalizations:
                file_name = file_name + '_normalized_{}'.format(
                    parameters['normalization'])
            fig.savefig(file_name + '_Spectrogram' + save_ext)

    if True:
        # saving all channels
        file_name = os.path.join(parameters['session_path'], 'MAP')
        if parameters['normalization'] in normalizations:
            file_name = file_name + \
                '_normalized_{}'.format(parameters['normalization'])
        map_fig.savefig(file_name + '_Spectrogram' + save_ext)

    return fig_list


def plot_spectrogram(session_data, parameters=None, * args, **kws):
    '''
    Plots the spectrogram of the given veda_eeg `session_data`

    :param session_data: the data arranged in the veda format
    :type session_data: data
    :param parameters: A dictionary containing all paramters for spectral analysis
    :type parameters: dict

    Example of parameters dictionary

    {'avaliable_channels': [1, 2, 3, 4, 5, 6],
     'baseline': '10',
     'd0': '20',
     'experiment': 'Single',
     'timeinterval': '10'}
    '''

    if parameters is None:
        parameters = session_data.get('meta_data', None)

    if 'baseline' not in parameters:
        raise Exception('No baseline parameter given, nothing to do')

    if 'available_channels' not in parameters:
        parameters['available_channels'] = range(
            session_data['voltage_series'].shape[0])

    if 'normalization' not in parameters:
        parameters['normalization'] = ''

    if 'save_ext' not in parameters:
        parameters['save_ext'] = '.pdf'

    save_ext = parameters['save_ext']

    baseline = float(parameters['baseline'])
    time_interval = float(parameters.get('timeinterval', 10))
    experiment = parameters['experiment']

    msg = '''Parameters: {}'''.format(pprint.pformat(parameters))
    print(msg)

    if experiment.upper() == 'SINGLE':
        d0 = 1
        d1 = 32
        dose_interval = 0.5

    msg = 'Computing spectrogram...'
    print(msg)
    freqs, lags, sp_db = sp.spectra_analysis(session_data, *args, **kws)
    msg = 'Done'
    print(msg)

    fig_list = []

    map_fig, axs = pyplot.subplots(
        3, 2, sharex=True, sharey=True, figsize=(11, 17))

    for chan in parameters['available_channels']:
        fig = pyplot.figure(figsize=(11, 8.5))
        ax_0 = pyplot.subplot(2, 2, 1)
        cmap = pyplot.get_cmap('viridis')
        hf = 60
        lf = 0

        cut_off = sum(freqs < hf)
        start_f = sum(freqs < lf)
        #scale = (cut_off - start_f) / (lags.max() / 60)

        im = pyplot.imshow(sp_db[chan, start_f:cut_off, :],
                           cmap=cmap,
                           # aspect=scale,
                           origin='lower',
                           extent=[0, max(lags) / 60, lf, hf], interpolation='none')
        pyplot.xlabel('Time (min)')
        pyplot.ylabel('Frequency (Hz)')
        #divider = make_axes_locatable(ax_0)
        #cax = divider.append_axes("top", size="5%", pad=0.05)
        pyplot.colorbar(im)

        ax_1 = pyplot.subplot(2, 2, 2)

        intervals = np.arange(
            (lags.max() / 60. - baseline) / time_interval) * time_interval + baseline
        index_array = np.digitize(lags, intervals * 60)
        legend = []
        chan_name = session_data['voltage_header'][
            chan]['name']
        pyplot.title('chan_name: {}'.format(chan_name))
        cm = pyplot.get_cmap('Reds')(1. /
                                     np.arange((lags.max() / 60. - baseline) / time_interval + 1))

        ax_1.set_prop_cycle(cycler('color', cm))

        if chan_name.upper()[-2:] == 'FL':
            map_ax = axs[0, 0]

        elif chan_name.upper()[-2:] == 'FR':
            map_ax = axs[0, 1]

        elif chan_name.upper()[-2:] == 'PL':
            map_ax = axs[1, 0]

        elif chan_name.upper()[-2:] == 'PR':
            map_ax = axs[1, 1]

        elif chan_name.upper()[-2:] == 'OL':
            map_ax = axs[2, 0]

        elif chan_name.upper()[-2:] == 'OR':
            map_ax = axs[2, 1]

        else:
            map_ax = None

        if map_ax is not None:
            map_ax.set_prop_cycle(cycler('color', cm))

        for i in np.unique(index_array):
            # pdb.set_trace()
            pl_spect = np.nanmean(
                sp_db[chan, slice(start_f, cut_off), index_array == i], 0)
            if parameters['normalization'] is 'baseline':
                pl_spect = ((pl_spect + 100) / \
                            (np.nanmean(sp_db[chan, slice(start_f, cut_off), index_array == 0], 0)
                             + 100) - 1) * 7.6
            pyplot.plot(freqs[start_f:cut_off], pl_spect)
            legend.append(
                '{:2.0f} min'.format(np.mean(lags[index_array == i] / 60)))
            if map_ax is not None:
                map_ax.plot(freqs[start_f:cut_off], pl_spect)

        map_ax.legend(legend)
        map_ax.set_ylabel('PSD (db)')
        map_ax.set_xlabel('Frequency (Hz)')
        map_ax.set_title('Chan:{}'.format(chan_name))

        pyplot.legend(legend)
        # pyplot.xlim((0,20))
        pyplot.xlabel('Frequency (Hz)')
        pyplot.ylabel('PSD (db)')
        if parameters['normalization'] is 'baseline':
            map_ax.set_ylabel('%')
            map_ax.set_ylim((0, 2))
            pyplot.ylabel('%')
            pyplot.ylim((0, 2))

        ax_2 = pyplot.subplot(2, 2, 3)
        pyplot.plot(lags / 60, sp_db[chan, start_f:cut_off, :].mean(0))
        pyplot.xlabel('Time (min)')
        pyplot.ylabel('PSD (db)')

        # equalizing axes
        fig.tight_layout()
        pyplot.draw()
        ax_list = fig.get_axes()

        ax_0_pos = ax_list[0].get_position()

        ax_1_pos = ax_1.get_position()
        ax_2_pos = ax_2.get_position()

        # pdb.set_trace()
        ax_1.set_position(
            [ax_1_pos.x0, ax_0_pos.y0, ax_0_pos.width, ax_0_pos.height])
        ax_2.set_position(
            [ax_0_pos.x0, ax_2_pos.y0, ax_0_pos.width, ax_0_pos.height])

        fig_list.append(fig)

        if False:
            # saving individual channels
            file_name = os.path.join(parameters['session_path'], chan_name)
            if parameters['normalization'] == 'baseline':
                file_name = file_name + '_normalized'
            fig.savefig(file_name + '_Spectrogram' + save_ext)

    if False:
        # saving all channels
        file_name = os.path.join(parameters['session_path'], 'MAP')
        if parameters['normalization'] == 'baseline':
            file_name = file_name + '_normalized'
        map_fig.savefig(file_name + '_Spectrogram' + save_ext)

    return fig_list
