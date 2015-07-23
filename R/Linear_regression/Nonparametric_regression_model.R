#Fit a nonparametric regression model of dist on speed based on the dataset 'cars' in R

#1
#Fit the piecewise regression model and try different interval widths
data = cars
plot(data)
y = data$dist
x = data$speed
lm.sol = lm(y~x)
lm.seg1 = segmented(lm.sol,seg.Z=~x,psi=list(x=15))
summary(lm.seg1)
intercept(lm.seg1)
slope(lm.seg1)
lm.seg2 = segmented(lm.sol,seg.Z=~x,psi=list(x=c(10,20)))
summary(lm.seg2)
intercept(lm.seg2)
slope(lm.seg2)
#Plot the fitted regression lines and the observations in the same plot
plot(lm.seg1,main='Piecewise Regression',xlab='Speed',ylab='Dist',xlim=c(0,28),ylim=c(0,130),lty=1,col="red",lwd=3)
par(new=T)
plot(lm.seg2,xlab='',ylab='',xlim=c(0,28),ylim=c(0,130),lty=2,col="blue",lwd=3)
points(x,y)
legend(1,120,c("Model 1","Model 2"),col=c("red","blue"),lty=c(1,2),merge=T)
#Take the finest lattice and fit the model using LASSO penalty
x_matrix = model.matrix(lm.seg1)[,lm.seg1$nameUV$U]
lasso = lars(as.matrix(x_matrix),y,type="lasso",trace=T)
lasso
plot(lasso)
summary(lasso)

#2
#Estimate the regression curve using Gaussian kernel with different bandwidths
lm.smooth1=ksmooth(x,y,kernel="normal",bandwidth=1)
lm.smooth2=ksmooth(x,y,kernel="normal",bandwidth=2)
lm.smooth3=ksmooth(x,y,kernel="normal",bandwidth=5)
#Plot the fitted regression lines of different bandwidths and the observations in the same plot
plot(data,main='Guassian Kernel Smoothing',xlab='Speed',ylab='Dist',xlim=c(0,28),ylim=c(0,130))
lines(lm.smooth1,lty=1,col="purple",lwd=3)
lines(lm.smooth2,lty=2,col="blue",lwd=3)
lines(lm.smooth3,lty=3,col="red",lwd=3)
legend(0,130,c("Bandwidth 1","Bandwidth 2","Bandwidth 5"),col=c("purple","blue","red"),lty=c(1,2,3),merge=T)



