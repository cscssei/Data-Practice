# -*- coding: utf-8 -*-
"""
Created on Sun Oct  8 10:29:30 2017

@author: elain
"""

import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import matplotlib.pyplot as plt

data_train = pd.read_csv("Train.csv")
data_train.columns
data_train.info()
data_train.describe()

# data explore with plot
fig = plt.figure()
fig.set(alpha = 0.2) # plot color index

plt.subplot2grid((2,3),(0,0))
data_train.Survived.value_counts().plot(kind = 'bar')
plt.title("获救人数 （1为获救）")
plt.ylabel("人数")
