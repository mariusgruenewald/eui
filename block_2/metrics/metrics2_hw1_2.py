# -*- coding: utf-8 -*-
"""
Created on Sat Nov 20 14:32:04 2021

@author: Marius
"""

import pandas as pd
import numpy as np
import statsmodels.api as sm
from linearmodels.panel import PooledOLS

data = pd.read_stata(r'C:\Users\mariu\Documents\EUI_orga\eui\cameron.dta')
data_2 = pd.wide_to_long(data, ["lwage", "educ", "black", "hisp", "expersq",
                       "exper", "married", "union"], i="nr", j="year").reset_index()
print(data_2.describe())
year_dummies = pd.get_dummies(data_2["year"])
data_2 = pd.concat([data_2, year_dummies],axis=1)
data_2 = data_2.set_index(["nr", "year"])

exog_vars = ["black", "hisp", "exper", "expersq",
             "married", "educ", "union", 1981, 1982, 1983, 1984, 1985, 1986, 1987]
exog = sm.add_constant(data_2[exog_vars])
mod = PooledOLS(data_2.lwage, exog)
pooled_res = mod.fit()
print(pooled_res)

from linearmodels.panel import RandomEffects
mod_2 = RandomEffects(data_2.lwage, exog)
random_res = mod_2.fit(cov_type="robust")
print(random_res)

from linearmodels.panel import PanelOLS

exog_2 = ["exper","expersq","married", "union"]
exog_2 = sm.add_constant(data_2[exog_2])
mod_3 = PanelOLS(data_2.lwage, exog_2, time_effects=True)
fe_res = mod_3.fit(cov_type="robust")
print(fe_res)

mod_4 = PanelOLS(data_2.lwage, exog_2, entity_effects=True)
fe_res_2 = mod_4.fit(cov_type="robust")
print(fe_res_2)


exog_3 = ["expersq","married", "union"]
exog_3 = sm.add_constant(data_2[exog_3])
mod_5 = PanelOLS(data_2.lwage, exog_3, time_effects=True, entity_effects=True)
fe_res_3 = mod_5.fit(cov_type="clustered", cluster_entity=True)
print(fe_res_3)


from linearmodels.panel import FirstDifferenceOLS
from scipy import linalg

exog_4 = ["union", "married", "expersq", "exper"]
exog_4 = data_2[exog_4]
mod_6 = FirstDifferenceOLS(data_2.lwage, exog_4)
fd_res = mod_6.fit()
print(fd_res)


# Create an Hausmann test following a Chi-squared distribution

diff_params = random_res.params[["expersq", "union", "married"]] - fe_res_3.params[["expersq", "union", "married"]]
var_mat_re = random_res.cov[["expersq", "union", "married"]]
var_mat_re = var_mat_re["expersq", "union", "married"]

var_mat_fe = fe_res_3.cov[["expersq", "union", "married"]]
var_mat_fe = np.append(var_mat_fe, fe_res_3.cov.iat[2,2])


diff_var = var_mat_fe - var_mat_re
diff_paramt = pd.DataFrame(data= [diff_params])

pinv = np.linalg.pinv([diff_var])
hausmann = diff_paramt*pinv*diff_params

from scipy.stats import chi2_contingency 

stat, p, dof, exp = chi2_contingency(hausmann) 
 
print(dof)

significance_level = 0.05
print("p value: " + str(p))
if p <= significance_level: 
    print('Reject NULL HYPOTHESIS') 
else: 
    print('ACCEPT NULL HYPOTHESIS')

# Serial correlation in the error terms.
resid_fd = pd.DataFrame(fd_res.resids.reset_index())
for i in resid_fd['nr']:
    resid_fd_red = resid_fd[resid_fd["nr"] == i] # DataFrame with only the relevant individual
    resid_fd.loc[resid_fd["nr"]==i, "residual_lag"] = resid_fd_red["residual"].shift(periods=1) # generate ind-spec. lag
    

resid_fd.dropna(inplace=True)
resid_fd = resid_fd.set_index(["nr","year"])
exog_err = sm.add_constant(resid_fd["residual_lag"])
mod_err = PooledOLS(resid_fd.residual, exog_err)
pooled_err = mod_err.fit()
print(pooled_err)


## i)
for year in (1980,1981,1982,1983,1984,1985,1986,1987):
    new_col = "educ_" + str(year)
    data_2[new_col] = data_2["educ"] * data_2[year]
    
exog_vars_educ = ["expersq","married", "union", "educ_1980",
             "educ_1981", "educ_1982", "educ_1983","educ_1984", "educ_1985", 
             "educ_1986"]    

exog_vars_educ = sm.add_constant(data_2[exog_vars_educ])
mod_educ = PanelOLS(data_2.lwage, exog_vars_educ, entity_effects=True, time_effects=True)
pooled_educ = mod_educ.fit()
print(pooled_educ)

exog_vars_educ_2 = ["expersq","married", "union"]    

exog_vars_educ_2 = sm.add_constant(data_2[exog_vars_educ_2])
mod_educ_2 = PanelOLS(data_2.lwage, exog_vars_educ_2, entity_effects=True, time_effects=True)
pooled_educ_2 = mod_educ_2.fit()
print(pooled_educ_2)

f_statistic = ((pooled_educ_2.resid_ss - pooled_educ.resid_ss)/(7))/((pooled_educ.resid_ss)/
               (len(data_2)-len(data["nr"].unique())-17-1))



