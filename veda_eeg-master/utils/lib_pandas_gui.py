'''
Created on Sep 25, 2015

@author: scaglionea
'''
# try:
from PyQt4 import QtCore, QtGui
from PyQt4.QtGui import QWidget
# except:
#     from PyQt5 import QtCore, QtGui
#     from PyQt5.QtWidgets import QWidget
    
import numpy as np
import os, path

__updated__ = "2015-11-04"
__version__ = (0,0,0)

class PandasDataFrameEditableModel(QtCore.QAbstractTableModel):

    def __init__(self, parent=None, data_frame=None):
        super(PandasDataFrameEditableModel, self).__init__(parent)
        self.data_frame = data_frame
        self.columnFormat = {}  # format columns

    def setFormat(self, fmt):
        """ 
        set string formatting for the output 
        example : format = {'close':"%.2f"}
        """

        self.columnFormat = fmt

    def setDataFrame(self, dataFrame):

        self.data_frame = dataFrame
        self.signalUpdate()

    def signalUpdate(self):
        ''' tell viewers to update their data (this is full update, not efficient)'''
        self.layoutChanged.emit()

    def __repr__(self):
        return str(self.data_frame)

    def update(self, dataIn):
        print('Updating Model')
        self.data_frame = dataIn
        self.signalUpdate()
        # print 'Datatable : {0}'.format(self.datatable)

    def rowCount(self, parent=QtCore.QModelIndex()):
        return len(self.data_frame.index)

    def columnCount(self, parent=QtCore.QModelIndex()):
        return len(self.data_frame.columns.values)

    def data(self, index, role=QtCore.Qt.DisplayRole):

        if role == QtCore.Qt.DisplayRole:
            i = index.row()
            j = index.column()
            # print(self.data_frame.iget_value(i,j))
            return str(self.data_frame.iget_value(i, j))

        if role == QtCore.Qt.EditRole:
            i, j = index.row(), index.column()
            dtype = self.data_frame.dtypes.tolist()[j]
            value = self.data_frame.iget_value(i, j)
            if np.issubdtype(dtype, np.float):
                val = float(value)
            elif np.issubdtype(dtype, np.int):
                val = int(value)
            else:
                val = str(value)

            return QtCore.QVariant(val)

        return QtCore.QVariant()

    def setData(self, index, value, role):
        if role == QtCore.Qt.EditRole:
            if index.isValid():
                row, column = index.row(), index.column()
                # get column dtype
                dtype = self.data_frame.dtypes.tolist()[column]

                if np.issubdtype(dtype, np.double):
                    val, ok = value.toDouble()
                elif np.issubdtype(dtype, np.float):
                    val, ok = value.toFloat()
                elif np.issubdtype(dtype, np.int):
                    val, ok = value.toInt()
                else:
                    val = value.toString()
                    ok = True

                if ok:

                    self.data_frame.iloc[row, column] = val
                    return True

        return False

    def flags(self, index):
        flags = super(self.__class__, self).flags(index)

        flags |= QtCore.Qt.ItemIsEditable
        flags |= QtCore.Qt.ItemIsSelectable
        flags |= QtCore.Qt.ItemIsEnabled
        flags |= QtCore.Qt.ItemIsDragEnabled
        flags |= QtCore.Qt.ItemIsDropEnabled

        return flags

    def appendRow(self, index, data=0):
        self.data_frame.loc[index, :] = data
        self.signalUpdate()

    def sort(self, nCol, order):

        self.layoutAboutToBeChanged.emit()
        if order == QtCore.Qt.AscendingOrder:
            self.data_frame = self.data_frame.sort(
                columns=self.data_frame.columns[nCol], ascending=True)
        elif order == QtCore.Qt.DescendingOrder:
            self.data_frame = self.data_frame.sort(
                columns=self.data_frame.columns[nCol], ascending=False)

        self.layoutChanged.emit()

    def deleteRow(self, index):
        idx = self.data_frame.index[index]
        #self.beginRemoveRows(QModelIndex(), index,index)
        #self.df_mean = self.df_mean.drop(idx,axis=0)
        # self.endRemoveRows()
        # self.signalUpdate()

    def headerData(self, section, orientation, role):

        if role == QtCore.Qt.DisplayRole:

            if orientation == QtCore.Qt.Vertical:
                # print(section,orientation,role)
                return(QtCore.QString("{}".format(self.data_frame.index[section])))
            if orientation == QtCore.Qt.Horizontal:
                # print(section,orientation,role)
                return(QtCore.QString(self.data_frame.columns[section]))
            
        if role == QtCore.Qt.SizeHintRole:
            if orientation == QtCore.Qt.Vertical:
                return QtCore.QSize(100,100)

        return QtCore.QVariant()


class PandaDFViewer(QWidget):

    def __init__(self, DB, *args, **kwargs):
        super(PandaDFViewer, self).__init__(*args, **kwargs)
        df_mean = DB
        layout = QtGui.QVBoxLayout()
        geom = QtGui.QDesktopWidget().availableGeometry()
        self.resize(geom.bottom() * 2 / 3 + 70, geom.bottom() * 2 / 3)
        self.move(geom.topLeft().x(), geom.topLeft().y())
        self.show()
        self.raise_()
        #self.datatable = QtGui.QTableWidget()
        # self.datatable.setColumnCount(len(df_mean.columns))
        # self.datatable.setRowCount(len(df_mean.index))
        # for i in range(len(df_mean.index)):
        #    for j in range(len(df_mean.columns)):
        #        self.datatable.setItem(i,j,QtGui.QTableWidgetItem(str(df_mean.iget_value(i, j))))
        self.tableModel = PandasDataFrameEditableModel(self)
        self.tableModel.update(df_mean)
        self.dataTable = QtGui.QTableView()
        self.dataTable.setModel(self.tableModel)
        self.dataTable.setSortingEnabled(True)
        self.loadButton = QtGui.QPushButton('&Load DB')
        self.loadButton.clicked.connect(self.loadDB)
        layout.addWidget(self.dataTable)
        layout.addWidget(self.loadButton)
        self.setLayout(layout)
        self.show()
        self.raise_()

    def loadDB(self, checked, DB=None):
        print(self, DB)
        if DB is None:
            print('Loading DB')
            DBfileName = '~/Copy/PostDoc'
            DBfileName = str(
                QtGui.QFileDialog.getOpenFileName(directory=DBfileName))
            _, ext = os.path.splitext(DBfileName)
            if ext == '.h5':
                DB = lib_pd.load_beh_DB(DBLoc=DBfileName)
                columns = DB.columns.tolist()
                columns.remove('Subject')
                columns = ['Subject'] + columns
                DB = DB[columns]
                DB.sort(['Subject', 'Date'], ascending=[1, 0], inplace=True)
                self.tableModel.update(DB)
                self.update()
