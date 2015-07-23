#W4400_Homework2_Problem3
#Apply a support vector machine to classify hand-written digits

#1a
#Inputs
#data: a matrix with one data point per row
#label: corresponding class labels
#cost: cost parameters
#k: number of folds
#Outputs
#rate: misclassificaiton rate
SVM_linear <- function(data,label,cost,k){
  size <- c(1:dim(data)[1])
  fold <- createFolds(size,k=k) # randomly select test data
  error <- rep(0,length(label)) # initial of classification rate
  for (i in 1:length(cost)){
    for (j in 1:k){
      model1 <- svm(data[-fold[[j]],],label[-fold[[j]]],type='C',kernel='linear',cost=cost[i],gamma=0) 
      pred <- predict(model1,data[fold[[j]],])
      error[i] <- error[i]+sum(pred!=label[fold[[j]]])
    } 
  }
  rate <- error/length(label)
  return(rate) 
}

set.seed(1)
index_test <- sample(1:dim(uspsdata)[1],40)
data_test <- uspsdata[index_test,]
data_train <- uspsdata[-index_test,] 
y_test <- uspscl$V1[index_test]
y_train <- uspscl$V1[-index_test]
cost <- exp(-seq(1,10,0.5))
error_linear <- SVM_linear(data_train,y_train,cost,5) 
qplot(cost,error_linear[1],geom="line",xlab="Cost",ylab="Misclassification rate",ylim=c(0,1),main="Misclassification rate in linear case")

#1b
#Inputs
#data: a matrix with one data point per row
#label: corresponding class labels
#cost: cost parameters
#gamma: gamma parameters
#k: number of folds
#Outputs
#rate: misclassificaiton rate
SVM_kernel <- function(data,label,cost,gamma,k){
  size <- c(1:dim(data)[1])
  fold <- createFolds(size,k=k) # randomly select test data
  error <- matrix(rep(0,length(gamma)*length(cost)),ncol=length(cost),nrow=length(gamma)) # initial of classification rate
  for (j in 1:length(gamma)){
    for (i in 1:length(cost)){ 
      for (n in 1:k){
        model2 <- svm(data[-fold[[n]],],label[-fold[[n]]],type='C',kernel='radial',cost=cost[i],gamma=gamma[j]) 
        pred <- predict(model2,data[fold[[n]],])
        error[j,i] <- error[j,i]+sum(pred!=label[fold[[n]]])
      }
    }
  }
  rate <- error/length(label)
  return(rate) 
}

cost2 <- seq(0.1,2,0.1)
gamma <- c(0.0001,0.001,0.01,0.1)
error_kernel <- SVM_kernel(data_train,y_train,cost2,gamma,5) 
gamma_color <- c("0.0001"=1,"0.001"=2,"0.01"=3,"0.1"=4) 
ggplot()+geom_line(aes(x=cost2,y=error_kernel[1,],color="0.0001"))+
  geom_line(aes(x=cost2,y=error_kernel[2,],color ="0.001"))+ 
  geom_line(aes(x=cost2,y=error_kernel[3,],color ="0.01"))+
  geom_line(aes(x=cost2,y=error_kernel[4,],color="0.1"))+
  xlab("Cost")+ylab("Misclassification rate")+scale_color_manual(name="Gamma",values=gamma_color)+ggtitle("Misclassification rate in non-linear case")

#2
#Report the test set estimates of the misclassification rates for both cases 
test_linear <- svm(data_test,y_test,type='C',kernel='linear',cost=0.1,gamma=0)
pred_linear <- predict(test_linear,data_test) 
sum(pred_linear != y_test)/40
test_kernel <- svm(data_test,y_test,type='C',kernal='radial',cost=1,gamma=0.001)
pred_kernel <- predict(test_kernel,data_test) 
sum(pred_kernel != y_test)/40
