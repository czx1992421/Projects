__author__ = 'gangao'

import sys
import numpy as np
import pandas as pd
import os
import random

import sklearn.linear_model as lm
from sklearn import cross_validation as cv

from scipy.stats import linregress

import statsmodels.api as sm
import pylab as plt

input = 'raw_data_GB.csv'

input_data = pd.read_csv(input)

predictors = ['transactionShares', 'transactionPrice', 'dollarValue', 'totalHoldings', 'deltaOwned',
              'alpha1Day', 'alpha1Month', 'alpha2Month', 'alpha3Month', 'alpha1Year', 'alpha1week',
              'alpha6Month', 'alpha2week', 'alpha3week', 'GT', 'reversal', 'startPrice',
              'var20', 'var90', 'var180', 'investorType', 'dollarvolume', 'mktcap_avg', 'last_buy',
              'num_insider', 'adjusted_all_close_ciq', 'win1Day', 'win1week', 'win2week', 'win3week',
              'win1Month', 'win2Month', 'win3Month', 'win6Month', 'win1Year', 'n1Day', 'n1week', 'n2week',
              'n3week', 'n1Month', 'n2Month', 'n3Month', 'n6Month', 'n1Year']

response = ['return1week']

X = input_data[predictors]

# Standardize data to have zero mean and unit standard deviation
X = (X - np.mean(X))/np.std(X)

# Replace null value with the mean (which is 0).

X = X.fillna(X.mean(), inplace=True)
# X = X.iloc[pd.isnull(X[predictors])==True,]
Y = input_data[response]

Y = (Y - np.mean(Y))/np.std(Y)

Y = Y.fillna(Y.mean(), inplace=True)

random.seed(1)

# run the cross validation for 5 times
nrep = 5

# conduct 10 folds cross-validation
nfold = 10

# initialize the test error list
kf_rmse_linear = [0]*nfold
kf_rmse_robust = [0]*nfold

cv_rmse_linear = [0]*nrep
cv_rmse_robust = [0]*nrep

for irep in range(nrep):
    kf = cv.KFold(n=len(X), n_folds=nfold, shuffle=True)
    i = 0
    threshold_lda = 0
    n = 0
    for train_index, test_index in kf:

        X_train, X_test = X.iloc[train_index, :], X.iloc[test_index, :]
        Y_train, Y_test = Y.iloc[train_index, :], Y.iloc[test_index, :]

        X_train = np.array(X_train)
        Y_train = np.array(Y_train)
        #linear_reg = lm.LinearRegression()
        #linear_reg.fit(X_train,Y_train)

        #robust_reg = lm.RANSACRegressor(lm.LinearRegression())
        #robust_reg.fit(X_train,Y_train)

        #pred_Y_linear_reg = linear_reg.predict(X_test)
        #pred_Y_robust_reg = robust_reg.predict(X_test)

        #kf_rmse_linear[i] = np.sqrt(np.sum((Y_test - pred_Y_linear_reg)**2)/len(Y_test))
        #kf_rmse_robust[i] = np.sqrt(np.sum((Y_test - pred_Y_robust_reg)**2)/len(Y_test))

        X_train = sm.add_constant(X_train)
        model = sm.OLS(Y_train, X_train)
        i = i + 1

    cv_rmse_linear[irep] = np.mean(kf_rmse_linear)
    cv_rmse_robust[irep] = np.mean(kf_rmse_robust)

rmse_linear = np.mean(cv_rmse_linear)
rmse_robust = np.mean(cv_rmse_robust)




