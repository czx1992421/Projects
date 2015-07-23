#W4400_Homework3_Problem1
#Implement the AdaBoost algorithm

#1
#Input
#X: a matrix the columns of which are the training vectors
#y: vectors containing the class labels
#B: number of weak learners
#Output
#alpha: vector of voting weights
#allPars: parameters of all weak learners
AdaBoost <- function(X,y,B){
  n <- dim(X)[1]
  w <- rep(1/n,n)
  alpha <- rep(0,B)
  allPars <- rep(list(list()),B) # initialize all the parameters
  for (b in 1:B){
    allPars[[b]] <- train(X,w,y) # train a weak leaner
    mistake <- (y != classify(X,allPars[[b]]))
    error <- (w %*% mistake / sum(w))[1] # compute error
    alpha[b] <- log((1-error)/error) # compute voting weights
    w <- w*exp(alpha[b]*mistake) # recompute weights
  }
  return(list(allPars=allPars,alpha=alpha))
}

#Input
#X: a matrix the columns of which are the training vectors
#alpha: vector of voting weights
#allPars: parameters of all weak learners
#Output
#c_hat: boosting classifier
agg_class <- function(X,alpha,allPars){
  n <- dim(X)[1]
  B <- length(alpha)
  label <- matrix(0,n,B) # initialize
  for (b in 1:B){
    label[,b] <- classify(X,allPars[[b]])
  } # evaluate the weak learner
  label <- label %*% alpha
  c_hat <- sign(label) 
  return(c_hat=c_hat) # return classifier
}

#2
#Input
#X: a matrix the columns of which are the training vectors
#w: vectors containing the weights
#y: vectors containing the class labels
#Output
#pars: a list which contains the parameters specifying the resulting classifier
train <- function(X,w,y){
  n <- dim(X)[1]
  c <- dim(X)[2]
  theta <- rep(0,c)
  m <- rep(0,c)
  mistake <- rep(0,c)
  for (j in 1:c){
    x <- X[,j]
    index <- sort.list(x)
    x0 <- X[index,j] # sort samples in ascending order along dimension
    w0 <- cumsum(w[index]*y[index]) 
    w0[duplicated(x0)==1] <- NA # shift the threshold to the larger elements
    w0_max <- max(abs(w0),T)
    index_max <- min(which(abs(w0)==w0_max))
    theta[j] <- x0[index_max]
    m[j] <- (w0[index_max]<0)*2-1
    y0 <- ((x0>theta[j])*2-1)*m[j]
    mistake[j] <- w %*% (y0 != y) # find the optimum threshold
  }
  mistake_min <- min(mistake)
  j <- min(which(mistake==mistake_min))
  pars <- list(j=j,theta=theta[j],m=m[j])
  return(pars=pars) # come up with result
}

#Input: 
#X: a matrix the columns of which are the training vectors
#pars: a list which contains the parameters specifying the resulting classifier
#Output:
#label: classification label
classify <- function(X,pars){
  j <- pars$j
  theta <- pars$theta
  m <- pars$m
  label <- (2*(X[,j]>theta)-1)*m
  return(label=label)
}

#3
#Run the algorithm on the data set and evaluate my results using cross validation
set.seed(1)
X <- uspsdata
y <- uspscl[,1]
B_max <- 100
CV <- 5
n <- 200
error_train <- matrix(0,B_max,CV)
error_test <- matrix(0,B_max,CV) # initialize
for (i in 1:CV){
  p <- sample(n)
  index <- p[1:floor(n/2)]
  X_train <- X[index,]
  X_test <- X[-index,] 
  y_train <- y[index]
  y_test <- y[-index] # divide dataset into training and test data
  alpha <- AdaBoost(X_train,y_train,B_max)$alpha
  allPars <- AdaBoost(X_train,y_train,B_max)$allPars
  for (B in 1:B_max){
    c_hat_train <- agg_class(X_train,alpha[1:B],allPars[1:B])
    c_hat_test <- agg_class(X_test,alpha[1:B],allPars[1:B])
    error_train[B,i] <- mean(y_train != c_hat_train)
    error_test[B,i] <- mean(y_test != c_hat_test)
  } # estimate the training and test error
}

