# -*- coding: utf-8 -*-
"""
Created on Mon Nov 22 11:59:49 2021

@author: Marius
"""

import pandas as pd
import numpy as np

data_q1 = pd.read_excel(r'C:\Users\mariu\Documents\EUI_orga\eui\data_q1.xls')
data_q1.describe()

# For every variable
for col in ("y", "x1", "x2"):
    # Set up names for intermediate columns
    new_col = col + "_bar"
    new_col_lag = col + "_lag"
    new_col_2 = col + "_ddot"
    new_col_diff = col + "_diff"
    
    # loop through individuals
    for i in data_q1["i"]:
        data_q1_red = data_q1[data_q1["i"] == i] # DataFrame with only the relevant individual
        data_q1.loc[data_q1["i"] == i, new_col] = data_q1_red[col].mean() # generate ind-specific mean
        data_q1.loc[data_q1["i"] == i, new_col_lag] = data_q1_red[col].shift(periods=1) # generate ind-spec. lag
    
    # Generate demeaned vars
    data_q1[new_col_2] = data_q1[col] - data_q1[new_col]
    # Generate differenced vars
    data_q1[new_col_diff] = data_q1[col] - data_q1[new_col_lag]
    
# Now, ready for estimation with standard linear regression
# Fixed Effects
from linearmodels.panel import PooledOLS

data_q1 = data_q1.set_index(["i", "t"])
data_q1["const"] = 1 
exog_vars = data_q1[["x1_ddot", "x2_ddot"]]
model_fe = PooledOLS(data_q1["y_ddot"], exog_vars)
fe_res = model_fe.fit()
print(fe_res)

data_diff = data_q1.copy()
data_diff.dropna(inplace=True)
exog_vars_diff = data_diff[["x1_diff", "x2_diff"]]
model_fd = PooledOLS(data_diff["y_diff"], exog_vars_diff)
fd_res = model_fd.fit()
print(fd_res)



data_q1_2 = data_q1.reset_index()
data_q1_2 = data_q1_2[data_q1_2["t"]<=2]

for col in ("y", "x1", "x2"):
    # Set up names for intermediate columns
    new_col = col + "_bar"
    new_col_lag = col + "_lag"
    new_col_2 = col + "_ddot"
    new_col_diff = col + "_diff"
    
    # loop through individuals
    for i in (1,2,3,4):
        data_q1_2_red = data_q1_2[data_q1_2["i"] == i] # DataFrame with only the relevant individual
        data_q1_2.loc[data_q1_2["i"] == i, new_col] = data_q1_2_red[col].mean() # generate ind-specific mean
        data_q1_2.loc[data_q1_2["i"] == i, new_col_lag] = data_q1_2_red[col].shift(periods=1) # generate ind-spec. lag
    
    # Generate demeaned vars
    data_q1_2[new_col_2] = data_q1_2[col] - data_q1_2[new_col]
    # Generate differenced vars
    data_q1_2[new_col_diff] = data_q1_2[col] - data_q1_2[new_col_lag]
    
    

exog_vars = data_q1_2[["x1_ddot", "x2_ddot"]]
model_fe_red = sm.OLS(data_q1_2["y_ddot"], exog_vars)
fe_res_red = model_fe_red.fit()
print(fe_res_red.summary())

data_diff_2 = data_q1_2.copy()
data_diff_2.dropna(inplace=True)
exog_vars_diff = data_diff_2[["x1_diff", "x2_diff"]]
model_fd_2 = sm.OLS(data_diff_2["y_diff"], exog_vars_diff)
fd_res_2 = model_fd_2.fit()
print(fd_res_2.summary())











