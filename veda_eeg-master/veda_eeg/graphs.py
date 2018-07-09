'''
Created on Oct 25, 2017

@author: alessandro
'''
import numpy as np
import pandas as pd

labels = [r'$\alpha$\n t',
          r'$\beta_{4-8}$',
          r'$\gamma_{8-12}$',
          r'$\delta_{12-27}$',
          r'$\theta_{27-up}$',
          ]

labels = ['$\\alpha$\n $^{^{^{0.2-4 Hz}}}$',
          '$\\beta$\n $^{^{^{0.2-4 Hz}}}$',
          '$\\gamma$\n $^{^{^{0.2-4 Hz}}}$',
          '$\\delta$\n $^{^{^{0.2-4 Hz}}}$',
          '$\\theta$\n $^{^{^{0.2-4 Hz}}}$',
          ]

colors = [(153 / 256., 204 / 256., 0 / 256.),
          'g',
          'b', ]


def _init_(backend='Qt5Agg'):
    import matplotlib
    try:
        matplotlib.use(backend)
    except:
        matplotlib.use('Qt4Agg')


def stellar_plot(df_mean=None, ax=None, fig=None, ax_index=111, df_error=None, log_scale=False):

    #_init_()
    from matplotlib import pyplot as pyl
    theta = np.linspace(0, 2 * np.pi, 5, endpoint=False)
    if fig is None:
        fig = pyl.figure()
    if ax is None:
        ax = fig.add_subplot(ax_index, projection='polar')
        ax.set_theta_zero_location('N')
        ax.set_theta_direction(-1)
        ax.set_thetagrids(np.rad2deg(theta), labels=labels, fontsize=24)
        ax.set_frame_on(False)
        ticks = np.linspace(50, 200, 4)
        ticks_labels = ticks.astype(np.int)
        if log_scale:
            ticks = np.log2(ticks)

        ax.set_rgrids(ticks, ticks_labels, 70, fontsize=9)
        # ax.spines['polar'].set_visible(False)
        ax.xaxis.grid(True, color='black', linestyle='-',
                      linewidth=1.5, alpha=.7)
        ax.yaxis.grid(True, linestyle='--', color='black')
        ax.yaxis.grid(False)

        grid_50 = 50 * np.ones(5)
        grid_100 = 100 * np.ones(5)
        grid_150 = 150 * np.ones(5)
        grid_200 = 200 * np.ones(5)
        if log_scale:
            grid_50 = np.log2(grid_50)
            grid_100 = np.log2(grid_100)
            grid_150 = np.log2(grid_150)
            grid_200 = np.log2(grid_200)

        ax.fill(theta, grid_50, alpha=.5, fill=False, linestyle='--')
        ax.fill(theta, grid_100, alpha=.5, fill=False, linestyle='--')
        ax.fill(theta, grid_150, alpha=.5, fill=False, linestyle='--')
        ax.fill(theta, grid_200, alpha=.5, fill=False, linestyle='--')

        xlim = (32, 256)
        if log_scale:
            ax.set_rlim(np.log2(xlim))

    if df_mean is not None:
        for i, drug in enumerate(df_mean):
            y = df_mean[drug]
            if log_scale:
                y = np.log2(y)
            ax.fill(theta, y, alpha=0.5, color=colors[i])
            ax.plot(theta, y,
                    alpha=0.5, marker='o', color=colors[i])

        ax.legend(df_mean.keys(), loc=1, bbox_to_anchor=(1.3, 0.5))

    if df_error is not None:
        for i, drug in enumerate(df_error):
            y = df_mean[drug]
            y_err = np.vstack((- df_error[drug] + df_mean[drug], df_error[drug] + \
                               df_mean[drug])) - df_mean[drug].values.reshape(-1,)
            if log_scale:
                y = np.log2(y)
                y_err = np.log2(np.vstack((- df_error[drug] + df_mean[drug], df_error[drug] + \
                                           df_mean[drug]))) - np.log2(df_mean[drug]).values.reshape(-1,)

            ax.errorbar(theta,
                        y,
                        np.abs(y_err),
                        linewidth=0, elinewidth=4, color=colors[i], alpha=1, capthick=2
                        )

    return ax


if __name__ == '__main__':
    import pandas as pd
    from veda_eeg.graphs import stellar_plot
    df_mean = pd.DataFrame()
    df_mean['Cocaine'] = [100, 120, 130, 140, 160]
    df_mean['Heroin'] = [110, 80, 70, 50, 30]
    df_error = pd.DataFrame()
    df_error['Cocaine'] = [20, 10, 5, 5, 2]
    df_error['Heroin'] = [5, 10, 20, 5, 2]
    ax = stellar_plot(df_mean=df_mean, df_error=df_error, log_scale=True)
    ax = stellar_plot(df_mean=df_mean, df_error=df_error, log_scale=False)
