#!/usr/bin/env python
'''
Created on Mar 26, 2016-test linked resource

@author: scaglionea
'''

import pdb  # @UnusedImport
import functools
import sys
import os

# LOGGER -----------------------------------------------------------------
from utils.lib_logger import create_logger
logger = create_logger()


# version decorator sets a new field for the function called `__version__`
# to keep track of function version changes
def set_fun_ver(version=(0, 9, 0), field_name='__version__'):

    def set_fun_ver_decorator(func):

        @functools.wraps(func)
        def wrapper(*args, **kws):

            output = func(*args, **kws)
            return output

        if hasattr(func, field_name):
            msg = 'function `{}` has already a field `{}`. Nothing to do'.format(
                func.__name__, field_name)
            logger.warning(msg)
        else:
            setattr(wrapper, field_name, version)

        return wrapper

    return set_fun_ver_decorator
