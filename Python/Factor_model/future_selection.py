__author__ = 'Zhuxi'

import numpy as np
import pandas as pd
import random
import time
import matplotlib.pyplot as plt
from sklearn.linear_model import LassoCV, LassoLarsCV, LassoLarsIC
import statsmodels.api as sm
import statsmodels.formula.api as smf

input = '/Users/Jovial/Desktop/LMG/Future_selection/raw_data_GB_10_28_no_du.csv'
input_data = pd.read_csv(input)

predictors = ['transactionShares', 'transactionPrice', 'dollarValue', 'totalHoldings', 'deltaOwned',
              'GT', 'reversal', 'startPrice', 'var20', 'var90', 'var180', 'investorType', 'dollarvolume', 'mktcap_avg', 'last_buy',
              'num_insider', 'adjusted_all_close_ciq', 'win1Day', 'win1week', 'win2week', 'win3week',
              'win1Month', 'win2Month', 'win3Month', 'win6Month', 'win1Year']

response = ['return2week']
X = input_data[predictors]
# Standardize data to have zero mean and unit standard deviation
X = (X - np.mean(X)) / np.std(X)
# Replace null value with the mean (which is 0).
X = X.fillna(X.mean(), inplace=True)
X_matrix = X.as_matrix(columns=None)

Y = input_data[response]
Y = (Y - np.mean(Y)) / np.std(Y)
Y = Y.fillna(Y.mean(), inplace=True)
Y_matrix = Y.as_matrix(columns=None)
Y_matrix = Y_matrix.reshape(608, )

random.seed(1)

##############################################################################
# LassoLarsIC: least angle regression with BIC/AIC criterion

model_bic = LassoLarsIC(criterion='bic')
t1 = time.time()
model_bic.fit(X_matrix, Y_matrix)
t_bic = time.time() - t1
alpha_bic_ = model_bic.alpha_
ind_bic = np.nonzero(model_bic.coef_)
ind_bic

model_aic = LassoLarsIC(criterion='aic')
model_aic.fit(X_matrix, Y_matrix)
alpha_aic_ = model_aic.alpha_
ind_aic = np.nonzero(model_aic.coef_)
ind_aic

def plot_ic_criterion(model, name, color):
    alpha_ = model.alpha_
    alphas_ = model.alphas_
    criterion_ = model.criterion_
    plt.plot(-np.log10(alphas_), criterion_, '--', color=color,
             linewidth=3, label='%s criterion' % name)
    plt.axvline(-np.log10(alpha_), color=color, linewidth=3,
                label='alpha: %s estimate' % name)
    plt.xlabel('-log(alpha)')
    plt.ylabel('criterion')


plt.figure()
plot_ic_criterion(model_aic, 'AIC', 'b')
plot_ic_criterion(model_bic, 'BIC', 'r')
plt.legend()
plt.title('Information-criterion for model selection (training time %.3fs)'
          % t_bic)

##############################################################################
# LassoCV: coordinate descent

# Compute paths
print("Computing regularization path using the coordinate descent lasso...")
t1 = time.time()
model_CV = LassoCV(cv=20).fit(X_matrix, Y_matrix)
t_lasso_cv = time.time() - t1
ind_CV = np.nonzero(model_CV.coef_)
ind_CV

# Display results
m_log_alphas = -np.log10(model_CV.alphas_)

plt.figure()
ymin, ymax = 0, 1
plt.plot(m_log_alphas, model_CV.mse_path_, ':')
plt.plot(m_log_alphas, model_CV.mse_path_.mean(axis=-1), 'k',
         label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model_CV.alpha_), linestyle='--', color='k',
            label='alpha: CV estimate')

plt.legend()

plt.xlabel('-log(alpha)')
plt.ylabel('Mean square error')
plt.title('Mean square error on each fold: coordinate descent '
          '(train time: %.2fs)' % t_lasso_cv)
plt.axis('tight')
plt.ylim(ymin, ymax)

##############################################################################
# LassoLarsCV: least angle regression

# Compute paths
print("Computing regularization path using the Lars lasso...")
t1 = time.time()
model_LarsCV = LassoLarsCV(cv=20).fit(X_matrix, Y_matrix)
t_lasso_lars_cv = time.time() - t1
ind_LarsCV = np.nonzero(model_LarsCV.coef_)
ind_LarsCV

# Display results
m_log_alphas = -np.log10(model_LarsCV.cv_alphas_)

plt.figure()
plt.plot(m_log_alphas, model_LarsCV.cv_mse_path_, ':')
plt.plot(m_log_alphas, model_LarsCV.cv_mse_path_.mean(axis=-1), 'k',
         label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model_LarsCV.alpha_), linestyle='--', color='k',
            label='alpha CV')
plt.legend()

plt.xlabel('-log(alpha)')
plt.ylabel('Mean square error')
plt.title('Mean square error on each fold: Lars (train time: %.2fs)'
          % t_lasso_lars_cv)
plt.axis('tight')
plt.ylim(ymin, ymax)

plt.show()

##############################################################################
input_no_du = '/Users/Jovial/Desktop/LMG/Future_selection/raw_data_GB_10_28_no_du.csv'
input_data_no_du = pd.read_csv(input_no_du)

input_du = '/Users/Jovial/Desktop/LMG/Future_selection/raw_data_GB_10_28_du.csv'
input_data_du = pd.read_csv(input_du)

# Linear Regression
predictors_linear = ['var90', 'var180', 'dollarvolume']
response_linear = ['return2week']

predictors_linear = ['var20','var180','dollarvolume','win1Day','win1Month','win2Month','transactionPrice']
response_linear = ['return2week']

X_linear = input_data_no_du[predictors_linear]
X_linear = (X_linear - np.mean(X_linear)) / np.std(X_linear)
X_linear = X_linear.fillna(X_linear.mean(), inplace=True)
Y_linear = input_data_no_du[response_linear]
Y_linear = (Y_linear - np.mean(Y_linear)) / np.std(Y_linear)
Y_linear = Y_linear.fillna(Y_linear.mean(), inplace=True)
Y_linear_matrix = Y_linear.as_matrix(columns=None)

X_linear = input_data_du[predictors_linear]
X_linear = (X_linear - np.mean(X_linear)) / np.std(X_linear)
X_linear = X_linear.fillna(X_linear.mean(), inplace=True)
Y_linear = input_data_du[response_linear]
Y_linear = (Y_linear - np.mean(Y_linear)) / np.std(Y_linear)
Y_linear = Y_linear.fillna(Y_linear.mean(), inplace=True)
Y_linear_matrix = Y_linear.as_matrix(columns=None)

X_linear = sm.add_constant(X_linear)
model_linear = sm.OLS(Y_linear, X_linear).fit()
model_linear.summary()

# Linear Regression with interaction terms no du
model_linear_inter = smf.ols(
    formula='return2week ~ var20*var180*dollarvolume*win1Day*win1Month*win2Month*transactionPrice',
    data=input_data_no_du).fit()
model_linear_inter.summary()

# Linear Regression with interaction terms du
model_linear_inter = smf.ols(
    formula='return2week ~ var20*var180*dollarvolume*win1Day*win1Month*win2Month*transactionPrice',
    data=input_data_du).fit()
model_linear_inter.summary()




