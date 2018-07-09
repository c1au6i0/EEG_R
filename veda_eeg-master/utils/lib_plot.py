'''
Created on Jun 13, 2016

@author: scaglionea
'''

import matplotlib.pylab as pyl
import pandas as pd
import numpy as np

import lib_pandas_util


def imshow_df(df_mean, cmap='viridis', zscore=False):

    if type(df_mean) is not pd.DataFrame:
        return

    cmap = pyl.get_cmap(cmap)

    if zscore:
        df_mean = df_mean.apply(lib_pandas_util.zscore)

    df_mean = df_mean.T
    im = pyl.imshow(df_mean,
                    aspect=df_mean.shape[1] / df_mean.shape[0],
                    cmap=cmap,
                    extent=[df_mean.T.index[0], df_mean.T.index[-1], 0, df_mean.shape[0]])

    pyl.yticks(np.arange(df_mean.index.size) + .5, df_mean.index.format())
    
    ax = pyl.gca()
    pyl.colorbar(im, ax=ax)
    return im
