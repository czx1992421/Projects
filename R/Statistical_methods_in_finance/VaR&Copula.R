#Here we apply VaR and Copula to reflect the international market during the global financial crisis.
#As the conclusion, we find that the model combined with Clayton Copula and t-distribution is best predictive.

library(PerformanceAnalytics)
library(evir)
library(fGarch)
library(copula)
library(copBasic)
library(CDVine)
set.seed(1)

#Normal period
Data_Fin1 <- Data[2260:4075,c(1,8,10)]
colnames(Data_Fin1) <- c('Date','Germany','US')
#Financial crisis
Data_Fin3 <- Data[4076:4418,c(1,8,10)]
colnames(Data_Fin3) <- c('Date','Germany','US')
#Summarize data
#Mean
mean1_germany <- mean(Data_Fin1$Germany,na.rm=T)
mean1_us <- mean(Data_Fin1$US,na.rm=T)
mean2_germany <- mean(Data_Fin3$Germany,na.rm=T)
mean2_us <- mean(Data_Fin3$US,na.rm=T)
#Standard Deviation
sd1_germany <- sd(Data_Fin1$Germany,na.rm=T)
sd1_us <- sd(Data_Fin1$US,na.rm=T)
sd2_germany <- sd(Data_Fin3$Germany,na.rm=T)
sd2_us <- sd(Data_Fin3$US,na.rm=T)
#Minimum
min1_germany <- min(Data_Fin1$Germany,na.rm=T)
min1_us <- min(Data_Fin1$US,na.rm=T)
min2_germany <- min(Data_Fin3$Germany,na.rm=T)
min2_us <- min(Data_Fin3$US,na.rm=T)
#Median
med1_germany <- median(Data_Fin1$Germany,na.rm=T)
med1_us <- median(Data_Fin1$US,na.rm=T)
med2_germany <- median(Data_Fin3$Germany,na.rm=T)
med2_us <- median(Data_Fin3$US,na.rm=T)
#Maximum
max1_germany <- max(Data_Fin1$Germany,na.rm=T)
max1_us <- max(Data_Fin1$US,na.rm=T)
max2_germany <- max(Data_Fin3$Germany,na.rm=T)
max2_us <- max(Data_Fin3$US,na.rm=T)
#Correlation
Data_Fin1$Germany[is.na(Data_Fin1$Germany)] <- 0
Data_Fin1$US[is.na(Data_Fin1$US)] <- 0
cor1 <- cor(Data_Fin1$Germany,Data_Fin1$US,method='pearson')
Data_Fin3$Germany[is.na(Data_Fin3$Germany)] <- 0
Data_Fin3$US[is.na(Data_Fin3$US)] <- 0
cor2 <- cor(Data_Fin3$Germany,Data_Fin3$US,method='pearson')
#Kurtois
kurtosis1_germany <- kurtosis(Data_Fin1$Germany,na.rm=T,type=3)
kurtosis1_us <- kurtosis(Data_Fin1$US,na.rm=T,type=3)
kurtosis2_germany <- kurtosis(Data_Fin3$Germany,na.rm=T,type=3)
kurtosis2_us <- kurtosis(Data_Fin3$US,na.rm=T,type=3)
#Skewness
skewness1_germany <- skewness(Data_Fin1$Germany,na.rm=T,type=3)
skewness1_us <- skewness(Data_Fin1$US,na.rm=T,type=3)
skewness2_germany <- skewness(Data_Fin3$Germany,na.rm=T,type=3)
skewness2_us <- skewness(Data_Fin3$US,na.rm=T,type=3)

#Check the normality 
qqnorm(Data_Fin1$Germany)
qqline(Data_Fin1$Germany)
qqnorm(Data_Fin1$US)
qqline(Data_Fin1$US)

#Check the iid
#Using Excel

#Check the linearity
plot(Data_Fin1$Germany,Data_Fin1$US,xlab='Germany',ylab='US')
fit <- lm(Data_Fin1$US~Data_Fin1$Germany)
summary(fit)
abline(4.273e-05,3.184e-01)

#t copula
#Initialize the variables 
Data_Fin2 <- Data[2260:4418,c(1,8,10)]
VaR1_norm <- c(0,0,0)
VaR2_norm <- c(0,0,0)
price_norm <- matrix(0,343,3)
tcount_norm <- c(0,0,0)
VaR1_t <- c(0,0,0)
VaR2_t <- c(0,0,0)
price_t <- matrix(0,343,3)
tcount_t <- c(0,0,0)
p <- c(0.01,0.05,0.1)
#Compute the frequency
for (i in 1:343){
  Germany1 <- Data_Fin2[i:(i+1815),2]
  Germany2 <- Germany1[!is.na(Germany1)]
  Germany1[is.na(Germany1)] <- 0
  US1 <- Data_Fin2[i:(i+1815),3]
  US2 <- US1[!is.na(US1)]
  US1[is.na(US1)] <- 0
  #Fit the time series model
  garch_germany_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='norm',trace=F)
  garch_us_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='norm',trace=F)
  garch_germany_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='std',trace=F)
  garch_us_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='std',trace=F)
  garch_germany_resid_norm <- residuals(garch_germany_norm,standardize=T)
  garch_us_resid_norm <- residuals(garch_us_norm,standardize=T)
  garch_germany_resid_t <- residuals(garch_germany_t,standardize=T)
  garch_us_resid_t <- residuals(garch_us_t,standardize=T)
  germany_cdf_norm <- pnorm(garch_germany_resid_norm)
  germany_cdf_t <- pt(garch_germany_resid_t,df=Inf)
  us_cdf_norm <- pnorm(garch_us_resid_norm)
  us_cdf_t <- pt(garch_us_resid_t,df=Inf)
  #Fit the copula model
  tcop_norm <- BiCopEst(germany_cdf_norm[1:min(length(Germany2),length(US2))],us_cdf_norm[1:min(length(Germany2),length(US2))],family=2,method='mle',se=T) 
  tcop_t <- BiCopEst(germany_cdf_t[1:min(length(Germany2),length(US2))],us_cdf_t[1:min(length(Germany2),length(US2))],family=2,method='mle',se=T) 
  theta_t_norm <- tcop_norm$par  
  theta_t_t <- tcop_t$par
  #Bootstrap
  sample_t_norm <- rCopula(5000,tCopula(theta_t_norm,dim=2))
  sample_t_t <- rCopula(5000,tCopula(theta_t_t,dim=2))
  w <- matrix(c(1/2,1/2),1,2) 
  predict_germany_mat_norm <- predict(garch_germany_norm,n.ahead=length(Germany2),mse='uncond',plot=F)
  predict_germany_mat_t <- predict(garch_germany_t,n.ahead=length(Germany2),mse='uncond',plot=F)
  w1_t_norm <- qnorm(sample_t_norm[,1])
  w1_t_t <- qt(sample_t_t[,1],df=Inf)
  error1_t_norm <- t(predict_germany_mat_norm[,3]%*%t(w1_t_norm))
  error1_t_t <- t(predict_germany_mat_t[,3]%*%t(w1_t_t))
  pred_germany_norm <- as.matrix(predict_germany_mat_norm[,1])
  pred_germany_t <- as.matrix(predict_germany_mat_t[,1])
  re1_t_norm <- matrix(rep(pred_germany_norm,each=5000),nrow=5000)
  re1_t_t <- matrix(rep(pred_germany_t,each=5000),nrow=5000)
  for1_t_norm <- re1_t_norm+error1_t_norm
  for1_t_t <- re1_t_t+error1_t_t
  predict_us_mat_norm <- predict(garch_us_norm,n.ahead=length(US2),mse='uncond',plot=F)
  predict_us_mat_t <- predict(garch_us_t,n.ahead=length(US2),mse='uncond',plot=F)
  w2_t_norm <- qnorm(sample_t_norm[,2])
  w2_t_t <- qt(sample_t_t[,2],df=Inf)
  error2_t_norm <- t(predict_us_mat_norm[,3]%*%t(w2_t_norm))
  error2_t_t <- t(predict_us_mat_t[,3]%*%t(w2_t_t))
  pred_us_norm <- as.matrix(predict_us_mat_norm[,1])
  pred_us_t <- as.matrix(predict_us_mat_t[,1])
  re2_t_norm <- matrix(rep(pred_us_norm,each=5000),nrow=5000)
  re2_t_t <- matrix(rep(pred_us_t,each=5000),nrow=5000)
  for2_t_norm <- re2_t_norm+error2_t_norm
  for2_t_t <- re2_t_t+error2_t_t
  #Compare the prdiction with actual price
  for (d in 1:3){
    VaR1_norm[d] <- quantile(for1_t_norm,p[d])
    VaR2_norm[d] <- quantile(for2_t_norm,p[d])
    price_norm[i,d] <- (c(VaR1_norm[d],VaR2_norm[d]))%*%t(w)
    if (price_norm[i,d]>(1/2*Germany1+1/2*US1)[d]) {tcount_norm[d] <- tcount_norm[d]+1}
    VaR1_t[d] <- quantile(for1_t_t,p[d])
    VaR2_t[d] <- quantile(for2_t_t,p[d])
    price_t[i,d] <- (c(VaR1_t[d],VaR2_t[d]))%*%t(w)
    if (price_t[i,d]>(1/2*Germany1+1/2*US1)[d]) {tcount_t[d] <- tcount_t[d]+1}
  } 
}

#Gussian copula
#Initialize the variables 
Data_Fin2 <- Data[2260:4418,c(1,8,10)]
VaR1_norm <- c(0,0,0)
VaR2_norm <- c(0,0,0)
price_norm <- matrix(0,343,3)
gucount_norm <- c(0,0,0)
VaR1_t <- c(0,0,0)
VaR2_t <- c(0,0,0)
price_t <- matrix(0,343,3)
gucount_t <- c(0,0,0)
p <- c(0.01,0.05,0.1)
#Compute the frequency
for (i in 1:343){
  Germany1 <- Data_Fin2[i:(i+1815),2]
  Germany2 <- Germany1[!is.na(Germany1)]
  Germany1[is.na(Germany1)] <- 0
  US1 <- Data_Fin2[i:(i+1815),3]
  US2 <- US1[!is.na(US1)]
  US1[is.na(US1)] <- 0
  #Fit the time series model
  garch_germany_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='norm',trace=F)
  garch_us_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='norm',trace=F)
  garch_germany_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='std',trace=F)
  garch_us_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='std',trace=F)
  garch_germany_resid_norm <- residuals(garch_germany_norm,standardize=T)
  garch_us_resid_norm <- residuals(garch_us_norm,standardize=T)
  garch_germany_resid_t <- residuals(garch_germany_t,standardize=T)
  garch_us_resid_t <- residuals(garch_us_t,standardize=T)
  germany_cdf_norm <- pnorm(garch_germany_resid_norm)
  germany_cdf_t <- pt(garch_germany_resid_t,df=Inf)
  us_cdf_norm <- pnorm(garch_us_resid_norm)
  us_cdf_t <- pt(garch_us_resid_t,df=Inf)
  #Fit the copula model
  gucop_norm <- BiCopEst(germany_cdf_norm[1:min(length(Germany2),length(US2))],us_cdf_norm[1:min(length(Germany2),length(US2))],family=1,method='mle',se=T) 
  gucop_t <- BiCopEst(germany_cdf_t[1:min(length(Germany2),length(US2))],us_cdf_t[1:min(length(Germany2),length(US2))],family=1,method='mle',se=T) 
  theta_gu_norm <- gucop_norm$par  
  theta_gu_t <- gucop_t$par
  #Bootstrap
  sample_gu_norm <- rCopula(5000,normalCopula(theta_gu_norm,dim=2))
  sample_gu_t <- rCopula(5000,normalCopula(theta_gu_t,dim=2))
  w <- matrix(c(1/2,1/2),1,2) 
  predict_germany_mat_norm <- predict(garch_germany_norm,n.ahead=length(Germany2),mse='uncond',plot=F)
  predict_germany_mat_t <- predict(garch_germany_t,n.ahead=length(Germany2),mse='uncond',plot=F)
  w1_gu_norm <- qnorm(sample_gu_norm[,1])
  w1_gu_t <- qt(sample_gu_t[,1],df=Inf)
  error1_gu_norm <- t(predict_germany_mat_norm[,3]%*%t(w1_gu_norm))
  error1_gu_t <- t(predict_germany_mat_t[,3]%*%t(w1_gu_t))
  pred_germany_norm <- as.matrix(predict_germany_mat_norm[,1])
  pred_germany_t <- as.matrix(predict_germany_mat_t[,1])
  re1_gu_norm <- matrix(rep(pred_germany_norm,each=5000),nrow=5000)
  re1_gu_t <- matrix(rep(pred_germany_t,each=5000),nrow=5000)
  for1_gu_norm <- re1_gu_norm+error1_gu_norm
  for1_gu_t <- re1_gu_t+error1_gu_t
  predict_us_mat_norm <- predict(garch_us_norm,n.ahead=length(US2),mse='uncond',plot=F)
  predict_us_mat_t <- predict(garch_us_t,n.ahead=length(US2),mse='uncond',plot=F)
  w2_gu_norm <- qnorm(sample_gu_norm[,2])
  w2_gu_t <- qt(sample_gu_t[,2],df=Inf)
  error2_gu_norm <- t(predict_us_mat_norm[,3]%*%t(w2_gu_norm))
  error2_gu_t <- t(predict_us_mat_t[,3]%*%t(w2_gu_t))
  pred_us_norm <- as.matrix(predict_us_mat_norm[,1])
  pred_us_t <- as.matrix(predict_us_mat_t[,1])
  re2_gu_norm <- matrix(rep(pred_us_norm,each=5000),nrow=5000)
  re2_gu_t <- matrix(rep(pred_us_t,each=5000),nrow=5000)
  for2_gu_norm <- re2_gu_norm+error2_gu_norm
  for2_gu_t <- re2_gu_t+error2_gu_t
  #Compare the prdiction with actual price
  for (d in 1:3){
    VaR1_norm[d] <- quantile(for1_gu_norm,p[d])
    VaR2_norm[d] <- quantile(for2_gu_norm,p[d])
    price_norm[i,d] <- (c(VaR1_norm[d],VaR2_norm[d]))%*%t(w)
    if (price_norm[i,d]>(1/2*Germany1+1/2*US1)[d]) {gucount_norm[d] <- gucount_norm[d]+1}
    VaR1_t[d] <- quantile(for1_gu_t,p[d])
    VaR2_t[d] <- quantile(for2_gu_t,p[d])
    price_t[i,d] <- (c(VaR1_t[d],VaR2_t[d]))%*%t(w)
    if (price_t[i,d]>(1/2*Germany1+1/2*US1)[d]) {gucount_t[d] <- gucount_t[d]+1}
  } 
}

#Clayton copula
#Initialize the variables 
Data_Fin2 <- Data[2260:4418,c(1,8,10)]
VaR1_norm <- c(0,0,0)
VaR2_norm <- c(0,0,0)
price_norm <- matrix(0,343,3)
ccount_norm <- c(0,0,0)
VaR1_t <- c(0,0,0)
VaR2_t <- c(0,0,0)
price_t <- matrix(0,343,3)
ccount_t <- c(0,0,0)
p <- c(0.01,0.05,0.1)
#Compute the frequency
for (i in 1:343){
  Germany1 <- Data_Fin2[i:(i+1815),2]
  Germany2 <- Germany1[!is.na(Germany1)]
  Germany1[is.na(Germany1)] <- 0
  US1 <- Data_Fin2[i:(i+1815),3]
  US2 <- US1[!is.na(US1)]
  US1[is.na(US1)] <- 0
  #Fit the time series model
  garch_germany_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='norm',trace=F)
  garch_us_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='norm',trace=F)
  garch_germany_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='std',trace=F)
  garch_us_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='std',trace=F)
  garch_germany_resid_norm <- residuals(garch_germany_norm,standardize=T)
  garch_us_resid_norm <- residuals(garch_us_norm,standardize=T)
  garch_germany_resid_t <- residuals(garch_germany_t,standardize=T)
  garch_us_resid_t <- residuals(garch_us_t,standardize=T)
  germany_cdf_norm <- pnorm(garch_germany_resid_norm)
  germany_cdf_t <- pt(garch_germany_resid_t,df=Inf)
  us_cdf_norm <- pnorm(garch_us_resid_norm)
  us_cdf_t <- pt(garch_us_resid_t,df=Inf)
  #Fit the copula model
  ccop_norm <- BiCopEst(germany_cdf_norm[1:min(length(Germany2),length(US2))],us_cdf_norm[1:min(length(Germany2),length(US2))],family=3,method='mle',se=T) 
  ccop_t <- BiCopEst(germany_cdf_t[1:min(length(Germany2),length(US2))],us_cdf_t[1:min(length(Germany2),length(US2))],family=3,method='mle',se=T) 
  theta_c_norm <- ccop_norm$par  
  theta_c_t <- ccop_t$par
  #Bootstrap
  sample_c_norm <- rCopula(5000,claytonCopula(theta_c_norm,dim=2))
  sample_c_t <- rCopula(5000,claytonCopula(theta_c_t,dim=2))
  w <- matrix(c(1/2,1/2),1,2) 
  predict_germany_mat_norm <- predict(garch_germany_norm,n.ahead=length(Germany2),mse='uncond',plot=F)
  predict_germany_mat_t <- predict(garch_germany_t,n.ahead=length(Germany2),mse='uncond',plot=F)
  w1_c_norm <- qnorm(sample_c_norm[,1])
  w1_c_t <- qt(sample_c_t[,1],df=Inf)
  error1_c_norm <- t(predict_germany_mat_norm[,3]%*%t(w1_c_norm))
  error1_c_t <- t(predict_germany_mat_t[,3]%*%t(w1_c_t))
  pred_germany_norm <- as.matrix(predict_germany_mat_norm[,1])
  pred_germany_t <- as.matrix(predict_germany_mat_t[,1])
  re1_c_norm <- matrix(rep(pred_germany_norm,each=5000),nrow=5000)
  re1_c_t <- matrix(rep(pred_germany_t,each=5000),nrow=5000)
  for1_c_norm <- re1_c_norm+error1_c_norm
  for1_c_t <- re1_c_t+error1_c_t
  predict_us_mat_norm <- predict(garch_us_norm,n.ahead=length(US2),mse='uncond',plot=F)
  predict_us_mat_t <- predict(garch_us_t,n.ahead=length(US2),mse='uncond',plot=F)
  w2_c_norm <- qnorm(sample_c_norm[,2])
  w2_c_t <- qt(sample_c_t[,2],df=Inf)
  error2_c_norm <- t(predict_us_mat_norm[,3]%*%t(w2_c_norm))
  error2_c_t <- t(predict_us_mat_t[,3]%*%t(w2_c_t))
  pred_us_norm <- as.matrix(predict_us_mat_norm[,1])
  pred_us_t <- as.matrix(predict_us_mat_t[,1])
  re2_c_norm <- matrix(rep(pred_us_norm,each=5000),nrow=5000)
  re2_c_t <- matrix(rep(pred_us_t,each=5000),nrow=5000)
  for2_c_norm <- re2_c_norm+error2_c_norm
  for2_c_t <- re2_c_t+error2_c_t
  #Compare the prdiction with actual price
  for (d in 1:3){
    VaR1_norm[d] <- quantile(for1_c_norm,p[d])
    VaR2_norm[d] <- quantile(for2_c_norm,p[d])
    price_norm[i,d] <- (c(VaR1_norm[d],VaR2_norm[d]))%*%t(w)
    if (price_norm[i,d]>(1/2*Germany1+1/2*US1)[d]) {ccount_norm[d] <- ccount_norm[d]+1}
    VaR1_t[d] <- quantile(for1_c_t,p[d])
    VaR2_t[d] <- quantile(for2_c_t,p[d])
    price_t[i,d] <- (c(VaR1_t[d],VaR2_t[d]))%*%t(w)
    if (price_t[i,d]>(1/2*Germany1+1/2*US1)[d]) {ccount_t[d] <- ccount_t[d]+1}
  } 
}

#Gumbel copula
#Initialize the variables 
Data_Fin2 <- Data[2260:4418,c(1,8,10)]
VaR1_norm <- c(0,0,0)
VaR2_norm <- c(0,0,0)
price_norm <- matrix(0,343,3)
gcount_norm <- c(0,0,0)
VaR1_t <- c(0,0,0)
VaR2_t <- c(0,0,0)
price_t <- matrix(0,343,3)
gcount_t <- c(0,0,0)
p <- c(0.01,0.05,0.1)
#Compute the frequency
for (i in 1:343){
  Germany1 <- Data_Fin2[i:(i+1815),2]
  Germany2 <- Germany1[!is.na(Germany1)]
  Germany1[is.na(Germany1)] <- 0
  US1 <- Data_Fin2[i:(i+1815),3]
  US2 <- US1[!is.na(US1)]
  US1[is.na(US1)] <- 0
  #Fit the time series model
  garch_germany_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='norm',trace=F)
  garch_us_norm <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='norm',trace=F)
  garch_germany_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(Germany2),cond.dist='std',trace=F)
  garch_us_t <- garchFit(formula=~arma(1,0)+garch(1,1),data=as.ts(US2),cond.dist='std',trace=F)
  garch_germany_resid_norm <- residuals(garch_germany_norm,standardize=T)
  garch_us_resid_norm <- residuals(garch_us_norm,standardize=T)
  garch_germany_resid_t <- residuals(garch_germany_t,standardize=T)
  garch_us_resid_t <- residuals(garch_us_t,standardize=T)
  germany_cdf_norm <- pnorm(garch_germany_resid_norm)
  germany_cdf_t <- pt(garch_germany_resid_t,df=Inf)
  us_cdf_norm <- pnorm(garch_us_resid_norm)
  us_cdf_t <- pt(garch_us_resid_t,df=Inf)
  #Fit the copula model
  gcop_norm <- BiCopEst(germany_cdf_norm[1:min(length(Germany2),length(US2))],us_cdf_norm[1:min(length(Germany2),length(US2))],family=4,method='mle',se=T) 
  gcop_t <- BiCopEst(germany_cdf_t[1:min(length(Germany2),length(US2))],us_cdf_t[1:min(length(Germany2),length(US2))],family=4,method='mle',se=T) 
  theta_g_norm <- gcop_norm$par  
  theta_g_t <- gcop_t$par
  #Bootstrap
  sample_g_norm <- rCopula(5000,gumbelCopula(theta_g_norm,dim=2))
  sample_g_t <- rCopula(5000,gumbelCopula(theta_g_t,dim=2))
  w <- matrix(c(1/2,1/2),1,2) 
  predict_germany_mat_norm <- predict(garch_germany_norm,n.ahead=length(Germany2),mse='uncond',plot=F)
  predict_germany_mat_t <- predict(garch_germany_t,n.ahead=length(Germany2),mse='uncond',plot=F)
  w1_g_norm <- qnorm(sample_g_norm[,1])
  w1_g_t <- qt(sample_g_t[,1],df=Inf)
  error1_g_norm <- t(predict_germany_mat_norm[,3]%*%t(w1_g_norm))
  error1_g_t <- t(predict_germany_mat_t[,3]%*%t(w1_g_t))
  pred_germany_norm <- as.matrix(predict_germany_mat_norm[,1])
  pred_germany_t <- as.matrix(predict_germany_mat_t[,1])
  re1_g_norm <- matrix(rep(pred_germany_norm,each=5000),nrow=5000)
  re1_g_t <- matrix(rep(pred_germany_t,each=5000),nrow=5000)
  for1_g_norm <- re1_g_norm+error1_g_norm
  for1_g_t <- re1_g_t+error1_g_t
  predict_us_mat_norm <- predict(garch_us_norm,n.ahead=length(US2),mse='uncond',plot=F)
  predict_us_mat_t <- predict(garch_us_t,n.ahead=length(US2),mse='uncond',plot=F)
  w2_g_norm <- qnorm(sample_g_norm[,2])
  w2_g_t <- qt(sample_g_t[,2],df=Inf)
  error2_g_norm <- t(predict_us_mat_norm[,3]%*%t(w2_g_norm))
  error2_g_t <- t(predict_us_mat_t[,3]%*%t(w2_g_t))
  pred_us_norm <- as.matrix(predict_us_mat_norm[,1])
  pred_us_t <- as.matrix(predict_us_mat_t[,1])
  re2_g_norm <- matrix(rep(pred_us_norm,each=5000),nrow=5000)
  re2_g_t <- matrix(rep(pred_us_t,each=5000),nrow=5000)
  for2_g_norm <- re2_g_norm+error2_g_norm
  for2_g_t <- re2_g_t+error2_g_t
  #Compare the prdiction with actual log-return
  for (d in 1:3){
    VaR1_norm[d] <- quantile(for1_g_norm,p[d])
    VaR2_norm[d] <- quantile(for2_g_norm,p[d])
    price_norm[i,d] <- (c(VaR1_norm[d],VaR2_norm[d]))%*%t(w)
    if (price_norm[i,d]>(1/2*Germany1+1/2*US1)[d]) {gcount_norm[d] <- gcount_norm[d]+1}
    VaR1_t[d] <- quantile(for1_g_t,p[d])
    VaR2_t[d] <- quantile(for2_g_t,p[d])
    price_t[i,d] <- (c(VaR1_t[d],VaR2_t[d]))%*%t(w)
    if (price_t[i,d]>(1/2*Germany1+1/2*US1)[d]) {gcount_t[d] <- gcount_t[d]+1}
  } 
}



