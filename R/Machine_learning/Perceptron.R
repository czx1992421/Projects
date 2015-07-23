#W4400_Homework2_Problem2
#Implement Perceptron

#1
#Inputs
#S: n by (d+1) sample matrix with last col 1
#z:  z[1:d] is the normal vector of a hyperplane, 
#    z[d+1] = -c is the negative offset parameter. 
#Outputs
#y: vector of the associated class labels
classify <- function(S,z){
  y=sign(S %*% z)
  y[y=0]=1
  return(y)
}

#2
#Inputs
#s: s is a n by (d+1) matrix of data points with last column 1
#y: length n vector of class assignments
#Outputs
#y: y is a vector of length n with each data point's classification
# label according to the hyperplane parameterized by z
perceptrain <- function(S,y){
  z = rep(1,times = dim(S)[2]) # initial normal vector of hyperplane
  Z_history <- z # initial history matrix
  k = 1 # initial learning rate
  # calculate the error 
  y0 <- sign(S %*% z)
  y0[y0=0]=1
  error <- (y0 != y) 
  while (all(y0 == y)==FALSE){
    gradient = t(y[error])%*% S[error,]
    z = z + (1/k)*gradient
    Z_history <- rbind(Z_history,z)
    y0 <- sign(S %*% t(z))
    y0[y0=0]=1
    error <- (y0 != y)
    k = k+1
  }
  return (list(z=z,Z_history=Z_history))
}

#Inputs
#w:  w[1:d] is the normal vector of a hyperplane, 
#    w[d+1] = -c is the negative offset parameter. 
#n: sample size
#Outputs
#S: n by (d+1) sample matrix with last col 1
#y: vector of the associated class labels
fakedata <- function(w, n){
  if(! require(MASS))
  {
    install.packages("MASS")
  }
  if(! require(mvtnorm))
  {
    install.packages("mvtnorm")
  }
  require(MASS)
  require(mvtnorm)
  # obtain dimension
  d <- length(w)-1
  # compute the offset vector and a Basis consisting of w and its nullspace
  offset <- -w[length(w)] * w[1:d] / sum(w[1:d]^2)
  Basis <- cbind(Null(w[1:d]), w[1:d])	 
  # Create samples, correct for offset, and extend
  # rmvnorm(n,mean,sigme) ~ generate n samples from N(0,I) distribution
  S <- rmvnorm(n, mean=rep(0,d),sigma = diag(1,d)) %*%  t(Basis) 
  S <- S + matrix(rep(offset,n),n,d,byrow=T)
  S <- cbind(S,1)
  # compute the class assignments
  y <- as.vector(sign(S %*% w))
  # add corrective factors to points that lie on the hyperplane.
  S[y==0,1:d] <- S[y==0,1:d] + runif(1,-0.5,0.5)*10^(-4)
  y = as.vector(sign(S %*% w))
  return(list(S=S, y=y))
} # end function fakedata

# train the perceptrain function
set.seed(1)
data = fakedata(c(1:6),100)
result = perceptrain(data$S,data$y)
classification = (classify(data$S,as.vector(result$z))==data$y)
table(classification)

#3
# Generate a new 3D random vector and check whether it is classified correctly
z = rnorm(mean=1,3)
set.seed(1)
data_train = fakedata(z,100)
set.seed(2)
data_test = fakedata(z,100)
result = perceptrain(data_train$S,data_train$y)
classification = (classify(data_test$S,as.vector(result$z))==data_test$y)
table(classification)

#4
# Plot the test data set and the classified hyperplane
data <- data.frame(x=data_test$S[,1],y=data_test$S[,2])
a = -(result$z[3]/result$z[2])
b = -(result$z[1]/result$z[2])
qplot(x,y,data=data,color=factor(data_test$y))+scale_color_manual(name="Category",values=factor(data_test$y))+geom_abline(intercept=a,slope=b)+ggtitle("Test data set and classified hyperplane")+xlab("x")+ylab("y")

# Plot the training data and the trajectory of the algorithm
trajectory = data.frame(intercept=-(result$Z_history[,3]/result$Z_history[,2]),slope=-(result$Z_history[,1]/result$Z_history[,2]),id=rep(1:dim(result$Z_history)[1]))
data <- data.frame(x=data_train$S[,1],y=data_train$S[,2])
color <- c("Line1"=3,"Line2"=4,"Line3"=5,"Line4"=6,"Line5"=7,"-1"=10,"1"=9)
ggplot()+geom_point(data=data,aes(x=x,y=y,color=factor(data_train$y)))+
  geom_abline(aes(intercept=trajectory$intercept[1],slope=trajectory$slope[1],color="Line1"))+
  geom_abline(aes(intercept=trajectory$intercept[2],slope=trajectory$slope[2],color="Line2"))+
  geom_abline(aes(intercept=trajectory$intercept[3],slope=trajectory$slope[3],color="Line3"))+
  geom_abline(aes(intercept=trajectory$intercept[4],slope=trajectory$slope[4],color="Line4"))+
  geom_abline(aes(intercept=trajectory$intercept[5],slope=trajectory$slope[5],color="Line5"))+
  ggtitle("Training data and trajectory of algorithm")+scale_color_manual(name="Legend",values=color)+xlab("x")+ylab("y")
