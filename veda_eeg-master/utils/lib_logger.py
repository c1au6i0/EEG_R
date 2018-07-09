# -*- coding: utf-8 -*-
import logging
import os
import sys
import functools
import traceback
import pdb  # @UnusedImport
import datetime
import time

HDLR = logging.StreamHandler(sys.stdout)

#=============================================================================


class DEBUGFormatter(logging.Formatter):

    '''Class that implements custom formatters for each type of level'''

    FORMATS = {logging.DEBUG: "\033[1m%(message)s\033[37m-DBG:%(module)s: %(lineno)d: %(message)s\033[0m",
               logging.INFO: "\033[1m%(message)-90s\033[34m-INFO:%(module)s:line %(lineno)s\033[0m",
               logging.WARN: "\033[1m%(message)s\033[33m-WARNING:%(module)s:line %(lineno)s-%(funcName)-15s()\033[0m",
               logging.ERROR: "\033[1m%(message)s\033[31m-ERROR: %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]\033[0m",
               logging.CRITICAL: "\033[1m%(message)s\033[31m-CRITICAL: %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]\033[0m",
               'DEFAULT': "\033[1m%(message)s\033[0m"}

    def format(self, record):
        if sys.version_info < (3, 0, 0):
            self._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        else:
            self._style._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        return logging.Formatter.format(self, record)


class SpecialFormatter(logging.Formatter):

    '''Class that implements custom formatters for each type of level'''

    FORMATS = {logging.DEBUG: "\033[1m%(message)s\033[37m-DBG:%(module)s: %(lineno)d: %(message)s\033[0m",
               logging.INFO: "\033[34m%(message)-80.80s |INFO: %(asctime)s|\033[0m",
               logging.WARN: "\033[1m%(message)s\033[33m-WARNING:%(module)s:line %(lineno)s-%(funcName)-15s()\033[0m",
               logging.ERROR: "\033[1m%(message)s\033[31m-ERROR: %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]\033[0m",
               logging.CRITICAL: "\033[1m%(message)s\033[31m-CRITICAL: %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]\033[0m",
               'DEFAULT': "\033[1m%(message)s\033[0m"}

    def format(self, record):
        if sys.version_info < (3, 0, 0):
            self._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        else:
            self._style._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        return logging.Formatter.format(self, record)


class SpecialFormatterFile(logging.Formatter):

    '''Class that implements custom formatters for each type of level'''

    FORMATS = {logging.DEBUG: "%(asctime)s - %(levelname)-8s : %(message)s | %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]",
               logging.INFO: "%(asctime)s - %(levelname)-8s : %(message)s | %(module)s:line %(lineno)s",
               logging.WARN: "%(asctime)s - %(levelname)-8s :%(message)s | %(module)s:line %(lineno)s-%(funcName)-15s() ",
               logging.ERROR: "%(asctime)s - %(levelname)-8s :%(message)s | %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]",
               logging.CRITICAL: "%(asctime)s - %(levelname)-8s :%(message)s | %(module)s:line %(lineno)s-%(funcName)-15s()[%(pathname)s]",
               'DEFAULT': "%(message)s"}

    def format(self, record):
        if sys.version_info < (3, 0, 0):
            self._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        else:
            self._style._fmt = self.FORMATS.get(
                record.levelno, self.FORMATS['DEFAULT'])
        return logging.Formatter.format(self, record)


class ExtraFilter(logging.Filter):

    '''
    Class that implements filters for all levels

    when logger is called with an extra dictionary with key extra other info are showed
    try:
    msg = 'error'
    logger.error(msg, extra={'lines':{'input1':1, 'input2':2}})
    '''

    def filter(self, record):
        if hasattr(record, 'exlns') and len(record.exlns) > 0:
            for k, v in record.exlns.iteritems():
                record.msg = record.msg + '\n\t' + k + ': ' + str(v)
        return super(ExtraFilter, self).filter(record)


#=============================================================================
def create_logger(name=None, level=logging.DEBUG, logfile=None):
    '''Utility function to create a logger object named after the caller
    namespace. It incorporates the formatting from :class:`.SpecialFormatter`
    and filters from :class:`ExtraFilter <utilities.ExtraFilter>`'''

    logging.basicConfig()

    if not name:
        # get the caller namespace in case none is provided
        import inspect
        caller = inspect.currentframe().f_back
        name = caller.f_globals['__name__']

        if os.path.isdir(os.path.expanduser('~/Library/Logs/')):
            logfile = os.path.expanduser('~/Library/Logs/')
        else:
            logfile = os.path.expanduser('~')

        try:
            logfile = os.path.join(logfile, 'Python_logs')
            if not os.path.isdir(logfile):
                os.mkdir(logfile)

            date_str = datetime.datetime.now().strftime('%Y-%m-%d')
            pid = os.getpid()

            rem_list = []
            for f in os.listdir(logfile):
                if os.stat(os.path.join(logfile, f)).st_mtime < time.time() - 30 * 86400:
                    rem_list.aapend(f)

            if len(rem_list) > 0:
                [os.remove(file_) for file_ in rem_list]

            logfile = os.path.join(
                logfile, date_str + '_pid_' + "{}".format(pid) + '.log')

        except:
            logfile = None

    # make a logger with that name
    logger = logging.getLogger(name)

    # set the filter of the logger accordingly to the filter class defined
    # above
    logger.addFilter(ExtraFilter())

    # set level
    logger.setLevel(level)

    # this is to avoid duplicate output
    logger.propagate = False

    # this is to clean the handlers when reloading module
    logger.handlers = []

    # creates a handler that prints to the std ouput
    hdlr = HDLR
    

    if logfile is not None:
        hdlr.setLevel(logging.WARNING)
        # define a Handler which writes INFO messages or higher to the
        # sys.stderr
        file_hdlr = logging.FileHandler(filename=logfile)
        file_hdlr.setLevel(logging.INFO)
        
        # tell the handler to use this format
        file_hdlr.setFormatter(SpecialFormatterFile())
        # add the handler to the root logger
        logger.addHandler(file_hdlr)

    # set the formatter as an instance of the class defined above
    hdlr.setFormatter(SpecialFormatter())

    # add the handler to the logger
    logger.addHandler(hdlr)

    return logger


def level_warning():
    def decorate(func):
        logger = create_logger()
        hnd = logger.handlers[0]

        def call():
            level = hnd.level
            hnd.setLevel('WARNING')
            result = func()
            hnd.setLevel(level)
            return result
        return call
    return decorate


def log_execution(logger=create_logger(), text=None, level=20, var=None):
    '''
    wrapper to log the execution of a function
    :param logger:
    :param msg:
    :param level:
    '''

    def log_execution_decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kws):
            if text is None:
                msg = 'Running `{}`'.format(func.__name__)
            else:
                msg = 'Running `{}`'.format(text)
            if var is not None:
                value = 'arg not found'
                if var in kws:
                    value = kws[var]
                elif var in func.__code__.co_varnames:
                    value = args[func.__code__.co_varnames.index(var)]
                msg = msg + ' for {} = {}'.format(var, value)
            logger.log(level, msg)
            curr_level = logger.level
            logger.setLevel("WARNING")
            try:
                output = func(*args, **kws)
                logger.setLevel(curr_level)
                msg = 'Done!'
                logger.log(level, msg)
            except Exception:
                # TODO: fix this mess to have a readable error
                logger.setLevel(curr_level)
                exc_info = sys.exc_info()
                stack = traceback.extract_stack()
                tb = traceback.extract_tb(exc_info[2])
                full_tb = stack[:-1] + tb
                exc_line = traceback.format_exception_only(*exc_info[:2])
                msg = 'Error: \n\t{}'.format(full_tb)
                # print(full_tb)
                logger.error(msg)
                output = None
            return output
        return wrapper
    return log_execution_decorator
