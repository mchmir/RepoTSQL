#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  TreeModel.py
#  
#  Copyright 2020 mchmir 

from PyQt5.QtCore import *
from PyQt5.QtWidgets import *

class TreeItem(object):
    def __init__(self, data, parent=None):
        self.parentItem = parent
        self.itemData = data
        self.childItems = []
        

    def appendChild(self, item):
        self.childItems.append(item)

    def child(self, row):
        return self.childItems[row]

    def childCount(self):
        return len(self.childItems)

    def columnCount(self):
        return len(self.itemData)

    def data(self, column):
        try:
            return self.itemData[column]
        except IndexError:
            return None

    def parent(self):
        return self.parentItem

    def row(self):
        if self.parentItem:
            return self.parentItem.childItems.index(self)
        return 0

    def proc(self):
        return self.data(2)


class TreeModel(QAbstractItemModel):
    def __init__(self, data, parent=None):
        super(TreeModel, self).__init__(parent)

        self.rootItem = TreeItem(("Инструмент", "Описание"))
        self.setupModelData(data.split('\n'), self.rootItem)


    def columnCount(self, parent = QModelIndex()):
        if parent.isValid():
            return parent.internalPointer().columnCount()
        else:
            return self.rootItem.columnCount()

    def data(self, index, role = Qt.DisplayRole):
        if not index.isValid():
            return None

        #if role != Qt.DisplayRole and role != Qt.UserRole :
        #    return None

        item = index.internalPointer()

        if role == Qt.DisplayRole:
            return item.data(index.column())

        if role == Qt.UserRole:
            return item.proc()
        return None

    def flags(self, index):
        if not index.isValid():
            return Qt.NoItemFlags

        return Qt.ItemIsEnabled | Qt.ItemIsSelectable

    def headerData(self, section, orientation, role):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            return self.rootItem.data(section)

        return None

    def index(self, row, column, parent = QModelIndex()):
        if not self.hasIndex(row, column, parent):
            print('no index',row, column, parent)
            return QModelIndex()

        if not parent.isValid():
            parentItem = self.rootItem
        else:
            parentItem = parent.internalPointer()

        childItem = parentItem.child(row)
        if childItem:
            return self.createIndex(row, column, childItem)
        else:
            return QModelIndex()

    def parent(self, index):
        if not index.isValid():
            return QModelIndex()

        childItem = index.internalPointer()
        parentItem = childItem.parent()

        if parentItem == self.rootItem:
            return QModelIndex()

        return self.createIndex(parentItem.row(), 0, parentItem)

    def rowCount(self, parent = QModelIndex()):
        if parent.column() > 0:
            return 0

        if not parent.isValid():
            parentItem = self.rootItem
        else:
            parentItem = parent.internalPointer()

        return parentItem.childCount()

    def setupModelData(self, lines, parent):
        parents = [parent]
        indentations = [0]

        number = 0

        while number < len(lines):
            position = 0
            l = str(lines[number],'utf-8')
            #print(l)
            while position < len(l):
                if l[position] != ' ':
                    break
                position += 1

            lineData = l[position:].strip()

            if lineData:
                # Read the column data from the rest of the line.
                columnData = [s for s in lineData.split('\t') if s]

                if position > indentations[-1]:
                    # The last child of the current parent is now the new
                    # parent unless the current parent has no children.

                    if parents[-1].childCount() > 0:
                        parents.append(parents[-1].child(parents[-1].childCount() - 1))
                        indentations.append(position)

                else:
                    while position < indentations[-1] and len(parents) > 0:
                        parents.pop()
                        indentations.pop()

                # Append a new item to the current parent's list of children.
                item = TreeItem(columnData, parents[-1])
                parents[-1].appendChild(item)

            number += 1

class TreeWidget(QTreeView):
    def __init__(self, parent=None):
        super(TreeWidget, self).__init__(parent)
          
        #self.doubleClicked.connect(self.handle_dblclick)
        
