'''
Created on Aug 19, 2016

@author: scaglionea
'''

import os
import itertools
import difflib


import numpy as np


from veda_eeg.io import OpenEphys
from veda_eeg.io import load_intan_rhd_format
import pdb
import dill
import gzip

from veda_eeg.utils import lib_files, lib_logger
logger = lib_logger.create_logger()

DATA_ROOT_FOLDER = None
DATA_FILTERS_INTAN = ['*.rhd']
DATA_FILTERS_OPENEPHYS = ['*.openephys']
DATA_FILTERS = DATA_FILTERS_INTAN + DATA_FILTERS_OPENEPHYS


def get_data_path():
    path = None
    if DATA_ROOT_FOLDER is not None:
        path = DATA_ROOT_FOLDER
    return path


def find_sessions(path=None, filters=None):
    '''

    :param path:
    :type path:
    :param filters:
    :type filters:
    '''

    if path is None:
        path = get_data_path()

    if path is None:
        return None

    if filters is None:
        filters = DATA_FILTERS

    _, data_dirs = lib_files.find_files(
        path, filters, return_dirs=True)

    msg = 'Found {} sessions'.format(len(data_dirs))
    logger.info(msg)

    return data_dirs


def get_session_meta_data(path=None):

    if path is None:
        path = get_data_path()

    if path is None:
        msg = 'Nothing to do'
        logger.info(msg)
        return

    txt_file = None
    if os.path.isdir(path):
        # gathering files
        files_list = lib_files.find_files(path, filters=DATA_FILTERS)
        # gathering metadata
        txt_file = lib_files.find_files(path, filters='*.txt')
        if len(txt_file) >= 1:
            txt_file = txt_file[0]
        else:
            txt_file = ''

    if os.path.isfile(path):
        path = os.path.abspath(path)
        files_list = [path]
        txt_file = os.path.splitext(path)[0] + '.txt'
        path = os.path.split(path)[0]

    if os.path.isfile(txt_file):
        msg = 'Found session txt file'
        logger.info(msg)
        with open(txt_file) as text:
            session_name = text.readline()
            meta_format = text.readline()
        #print(session_name, meta_format)
    else:
        session_name = files_list[0]
        meta_format = 'SUBJECT_DATE'

    meta = lib_files.get_fields_from_filename(
        session_name, meta_format, is_file_name=False)

    if len(lib_files.find_files(path, filters=DATA_FILTERS_INTAN)) > 0:
        meta['original_data_format'] = 'INTAN'
    else:
        meta['original_data_format'] = 'OPEN_EPHYS'

    meta['session_name'] = session_name.strip()
    meta['session_path'] = path

    return meta


def merge_intan_sessions(data_list=None):

    msg = 'Merging sessions, only merging aux and amplifier data'
    logger.warn(msg)

    headers_key = ['amplifier_channels',
                   'aux_input_channels',
                   'frequency_parameters']

    data_key = ['t_aux_input',
                't_amplifier',
                'amplifier_data',
                'aux_input_data']

    data_out = {'amplifier_channels': [],
                'aux_input_channels': [],
                'frequency_parameters': [],
                't_aux_input': [],
                't_amplifier': [],
                'amplifier_data': [],
                'aux_input_data': []}

    # header data first:

    for key in headers_key:
        gen = [d[key] for d in data_list]

        if isinstance(d[key], list):
            data_out[key].extend(itertools.chain(*gen))
        else:
            data_out[key].extend(itertools.chain(gen))

        data_out[key] = np.unique(data_out[key]).tolist()
        if len(data_out[key]) == 1:
            data_out[key] = data_out[key][0]

    # now the data:

    # first time indeces
    for key in ['t_aux_input', 't_amplifier']:
        data_out[key] = np.hstack((d[key] for d in data_list))

    # merging data:
    for chan in data_out['aux_input_channels']:
        gen = (d['aux_input_data'][d['aux_input_channels'].index(chan), :]
               if chan in d['aux_input_channels'] else
               np.nan * np.zeros_like(d['t_aux_input']) for d in data_list)
        chan_data = np.hstack(gen)
        data_out['aux_input_data'].append(chan_data)
    data_out['aux_input_data'] = np.vstack(data_out['aux_input_data'])

    for chan in data_out['amplifier_channels']:
        gen = (d['amplifier_data'][d['amplifier_channels'].index(chan), :]
               if chan in d['amplifier_channels'] else
               np.nan * np.zeros_like(d['t_amplifier']) for d in data_list)
        chan_data = np.hstack(gen)
        data_out['amplifier_data'].append(chan_data)
    data_out['amplifier_data'] = np.vstack(data_out['amplifier_data'])

    if sum(data_out['t_amplifier'] == 0) > 0:
        msg = 'Warning more than one separate recordings are being merged'
        logger.warn(msg)

    return data_out


def intan_to_veda(data):

    out = dict()
    out['voltage_series'] = data['amplifier_data']
    out['aux_series'] = data['aux_input_data']
    out['voltage_header'] = data['amplifier_channels']
    out['aux_header'] = data['aux_input_channels']
    # adding freq information to voltage_headers
    freq_info = data['frequency_parameters']
    key = 'voltage_header'
    # pdb.set_trace()
    for chan in out[key]:
        chan['sampling_freq'] = freq_info['amplifier_sample_rate']
        chan['low_cut_off_frequency'] = freq_info['desired_lower_bandwidth']
        chan['low_cut_off_order'] = None
        chan['low_cut_off_type'] = None
        chan['high_cut_off_frequency'] = freq_info['desired_upper_bandwidth']
        chan['high_cut_off_order'] = None
        chan['high_cut_off_type'] = None
        chan['notch_filter_frequency'] = freq_info['notch_filter_frequency']
        chan['sig_units'] = 'uV'
        chan['name'] = chan['custom_channel_name']
        chan['bank'] = chan['port_prefix']
        chan['pin'] = ['chip_channel']

    key = 'aux_header'
    for chan in out[key]:
        chan['sampling_freq'] = freq_info['aux_input_sample_rate']
        chan['sig_units'] = 'V'

    # data.pop('amplifier_data')
    # data.pop('aux_input_data')
    # data.pop('amplifier_channels')
    # data.pop('aux_input_channels')

    return out


def openephys_to_veda(data):

    out = dict()
    aux_channels = openephys_aux_channels()

    voltage_series_channels = openephys_continuous_channels()

    gen = (data[d]['data'] * float(data[d]['header']['bitVolts'])
           for d in data if d in voltage_series_channels)

    out['voltage_series'] = np.vstack(tuple(gen))
    gen = (data[d]['header'] for d in data if d in voltage_series_channels)
    out['voltage_header'] = list(tuple(gen))

    gen = (data[d]['data'] * float(data[d]['header']['bitVolts'])
           for d in data if d in aux_channels)
    out['aux_series'] = np.vstack(tuple(gen))
    gen = (data[d]['header'] for d in data if d in aux_channels)
    out['aux_header'] = list(tuple(gen))

    # finalize aux_header
    key = 'voltage_header'
    for chan in out[key]:
        chan['sampling_freq'] = int(chan['sampleRate'])
        #chan['low_cut_off_frequency'] = freq_info['desired_lower_bandwidth']
        #chan['low_cut_off_order'] = None
        #chan['low_cut_off_type'] = None
        #chan['high_cut_off_frequency'] = freq_info['desired_upper_bandwidth']
        #chan['high_cut_off_order'] = None
        #chan['high_cut_off_type'] = None
        #chan['notch_filter_frequency'] = freq_info['notch_filter_frequency']
        chan['sig_units'] = 'uV'
        chan['name'] = chan['channel']
        #chan['bank'] = chan['port_prefix']
        #chan['pin'] = ['chip_channel']

    key = 'aux_header'
    for chan in out[key]:
        chan['sampling_freq'] = int(chan['sampleRate'])
        chan['sig_units'] = 'V'

    return out

    for chan in voltage_series_channels:
        pass

    out['voltage_series'] = []
    out['aux_series'] = []
    out['voltage_header'] = []
    out['aux_header'] = []

    # adding freq information to voltage_headers
    freq_info = data['frequency_parameters']
    key = 'voltage_header'
    for chan in out[key]:
        chan['sampling_freq'] = freq_info['amplifier_sample_rate']
        chan['low_cut_off_frequency'] = freq_info['desired_lower_bandwidth']
        chan['low_cut_off_order'] = None
        chan['low_cut_off_type'] = None
        chan['high_cut_off_frequency'] = freq_info['desired_upper_bandwidth']
        chan['high_cut_off_order'] = None
        chan['high_cut_off_type'] = None
        chan['notch_filter_frequency'] = freq_info['notch_filter_frequency']
        chan['sig_units'] = 'uV'
        chan['name'] = chan['custom_channel_name']
        chan['bank'] = chan['port_prefix']
        chan['pin'] = ['chip_channel']

    key = 'aux_header'
    for chan in out[key]:
        chan['sampling_freq'] = freq_info['aux_input_sample_rate']
        chan['sig_units'] = 'V'

    # data.pop('amplifier_data')
    # data.pop('aux_input_data')
    # data.pop('amplifier_channels')
    # data.pop('aux_input_channels')

    return out


def import_session_intan(path, channels=None, return_original=False):
    msg = 'Importing intan files'
    logger.info(msg)

    if os.path.isfile(path):
        files_list = [os.path.abspath(path)]
    else:
        files_list = lib_files.find_files(path, filters=DATA_FILTERS_INTAN)

    if channels is None:
        channels = [1, 3, 5, 7, 24, 26, 28, 30]
        logger.warn(
            'Extracting only {} chip_channels'.format(channels))

    elif channels is 'all':
        channels = np.arange(32)

    try:
        data = map(load_intan_rhd_format.read_data, files_list)

        if len(data) > 1:
            data = merge_intan_sessions(data)

        if len(data) == 1:
            data = data[0]

        if return_original:
            return data

    except Exception as e:
        logger.warning('Error reading file: \n{}'.format(files_list[0]))

    # filtering on channels

    def chan_filter(chan, id_list=channels, port=None):

        if chan['chip_channel'] in id_list:
            if port is None:
                return True
            else:
                if chan['port_prefix'] == port:
                    return True
        return False

    # filtering on channels
    def chan_filter_name(chan, name_list=[], port=None):

        if chan['native_channel_name'] in name_list:
            if port is None:
                return True
            else:
                if chan['port_prefix'] == port:
                    return True
        return False

    chan_list = filter(chan_filter, data['amplifier_channels'])
    data['amplifier_channels'] = chan_list

    def read_single_file_data(file_name):

        if os.path.basename(file_name)[:3].lower() == 'amp':
            # amplifier data
            return np.fromfile(
                file_name, dtype=np.int16) * 0.195  # microVolts
        elif os.path.basename(file_name)[:3].lower() == 'aux':
            # aux data
            return np.fromfile(
                file_name, dtype=np.uint16) * 0.0000374  # Volts
        elif os.path.basename(file_name)[:3].lower() == 'vdd':
            # aux data
            return np.fromfile(
                file_name, dtype=np.uint16) * 0.0000748  # Volts

    if 'amplifier_data' not in data:
        # data not in rhd file

        amp_data_files = lib_files.find_files(path, filters=['*amp*.dat'])
        data_amp = map(read_single_file_data, amp_data_files)
        # pdb.set_trace()
        if len(data_amp) != len(chan_list) or 'amplifier_data' not in data:
            chan_name_list = [
                os.path.basename(file_name)[4:-4] for file_name in amp_data_files]

            def filter_fun(chan, chan_name_list=chan_name_list):
                return chan_filter_name(chan, chan_name_list)
            chan_list = filter(filter_fun, data['amplifier_channels'])
            data['amplifier_channels'] = chan_list
            data['amplifier_data'] = np.vstack(data_amp)

    if 'aux_input_data' not in data:

        aux_data_files = lib_files.find_files(path, filters=['*aux*.dat'])
        data_aux = map(read_single_file_data, aux_data_files)
        if len(data_aux) != len(data['aux_input_channels']) or 'aux_input_data' not in data:
            chan_name_list = [
                os.path.basename(file_name)[4:-4] for file_name in aux_data_files]

            def filter_fun(chan, chan_name_list=chan_name_list):
                return chan_filter_name(chan, chan_name_list)
            chan_list = filter(filter_fun, data['aux_input_channels'])
            data['aux_input_channels'] = chan_list
            data['aux_input_data'] = np.vstack(data_aux)

    chan_list = filter(chan_filter, data['amplifier_channels'])
    data['amplifier_channels'] = chan_list
    idx = np.sum([np.in1d(data['amplifier_channels'], chan)
                  for chan in chan_list], 0)
    # pdb.set_trace()

    data['amplifier_data'] = data['amplifier_data'][idx == 1, :]

    return intan_to_veda(data)


def openephys_continuous_channels(ids=None):

    if ids is None:
        ids = map(str, [8, 6, 4, 2, 25, 27, 29, 31])
        ids = ['CH' + id for id in ids]
    # custom naming used in some experiments
    ids = ids + ['PAR_R', 'OCC_R', 'FRO_R', 'PAR_L', 'OCC_L', 'FRO_L']

    channel_processors = ['100', '200', '300', '400']

    return ['_'.join([x, y]) for x, y in itertools.product(channel_processors, ids)]


def openephys_aux_channels(ids=None):

    if ids is None:
        ids = map('AUX{}'.format, [1, 2, 3])

    channel_processors = ['100', '200', '300', '400']

    chan_list = ['_'.join([x, y])
                 for x, y in itertools.product(channel_processors, ids)]

    return chan_list


def import_session_openephys(path, channels=None, return_original=False, infer_chan_names=False):
    msg = 'Importing OpenEphys files'
    logger.info(msg)
    data = OpenEphys.loadFolder(path)

    if return_original:
        return data

    if channels is None:
        channels = openephys_continuous_channels() + openephys_aux_channels()
        logger.warn(
            'Extracting only {} chip_channels'.format(channels))

    elif channels is 'all':
        channels = data.keys()

    out = dict()
    # pdb.set_trace()
    if infer_chan_names:
        for chan in channels:

            match = difflib.get_close_matches(chan, data.keys(), 1, .85)
            if match == []:
                continue
            out[chan] = data[match[0]]
            logger.info(match[0] + '-->' + chan)
    else:
        for chan in channels:

            if chan not in data:
                continue
            out[chan] = data[chan]
            logger.info(chan + '-->' + chan)

    return openephys_to_veda(out)


def import_session(path=None, save=False, *args, **kws):

    if path is None:
        path = get_data_path()

    if path is None:
        msg = 'Nothing to do'
        logger.info(msg)
        return

    file_ = None
    if os.path.isfile(path):
        path = os.path.abspath(path)
        file_ = path
        path = os.path.split(path)[0]

    path = find_sessions(path)[0]
    if len(path) == 0:
        return

    msg = 'Processing Session:{}'.format(os.path.split(path)[1])
    logger.info(msg)
    meta = get_session_meta_data(path)

    if file_ is not None:
        path = file_

    if meta['original_data_format'] == 'INTAN':
        data = import_session_intan(path, *args, **kws)
    else:
        data = import_session_openephys(path, *args, **kws)

    data['meta_data'] = meta

    if save:
        logger.info('Saving data')
        if os.path.isfile(path):
            root_dir = os.path.split(path)[0]
        else:
            root_dir = path
        file_name = os.path.join(
            root_dir, data['meta_data']['session_name'] + '.dill.gz')
        with gzip.open(file_name, 'wb') as stream:
            dill.dump(data, stream)
        logger.info('data saved in: {}'.format(file_name))
    return data


def load_session(file_name, compression='gzip'):

    with gzip.open(file_name, 'wb') as stream:
        data = dill.load(stream)

    # updating path
    if 'meta_data' in data:
        data['meta_data']['session_path'] = os.path.split(file_name)[0]

    return data


if __name__ == '__main__':
    pass
