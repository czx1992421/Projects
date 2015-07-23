#W4400_Homework4_Problem3
#Apply the EM algorithm and a finite mixture of multinomial distribution to the image segmentation problem

#1
#Input
#H: the matrix of input histogram
#K: the number of clusters
#tau: the threshold parameter
#Output
#m: index
#Implement the EM algorithm
MultinomialEM<-function(H,K,tau){
  a=dim(H)[1] #number of histograms
  b=dim(H)[2] #number of bins in each histogram
  iteration=1 #current iteration
  index=sample(1:a,K) #initialize the clusters
  t=H[index,] #initilize the assignment
  delta=1 #initialize a measure of the change of assignments
  c=rep(1,K)/K #initilize the mixture weights
  while(delta>tau){
    #E-step
    L=log(t)
    Phi=exp(H %*% t(L))
    Phi_weighted=Phi*c
    A=matrix(rep(1/rowSums(Phi_weighted),K),a,K)*Phi_weighted
    #M-step
    c=colSums(A)
    c=c/sum(c)
    t_old=t
    B=t(A)%*%H
    t=matrix(rep(1/rowSums(B),b),K,b)*B
    #Compute the change
    iteration=iteration+1
    delta=norm(t_old-t,type="O")
    #Return the index
    return(m=apply(A,1,which.max))
  }
}

#2
#Run the algorithm on the data set for different K and tau
H<-matrix(readBin("/Users/Jovial/Desktop/histograms.bin", "double", 640000), 40000, 16)
for (i in 1:40000){
  for (j in 1:16){
    if(H[i,j]==0)
      H[i,j]<-0.01
  }
}
m31 <- MultinomialEM(H,K=3,tau=0.01)
m32 <- MultinomialEM(H,K=3,tau=0.001)
m33 <- MultinomialEM(H,K=3,tau=0.0001)
m41 <- MultinomialEM(H,K=4,tau=0.01)
m42 <- MultinomialEM(H,K=4,tau=0.001)
m43 <- MultinomialEM(H,K=4,tau=0.0001)
m51 <- MultinomialEM(H,K=5,tau=0.01)
m52 <- MultinomialEM(H,K=5,tau=0.001)
m53 <- MultinomialEM(H,K=5,tau=0.0001)

#3
#Visualize the results as an image
plot <- function(H,K,tau){
  par(mfrow=c(length(K),length(tau)))
  for (i in 1:length(K)){
    for (j in 1:length(tau)){
      m <- MultinomialEM(H,K[i],tau[j])
      m_matrix <- matrix(m,nrow=200,byrow=T)
      m_graph <- NULL
      for (n in 0:(dim(m_matrix)[1]-1)){
        m_graph <- cbind(m_graph,m_matrix[dim(m_matrix)[1]-n,])
      }
      image(x=1:200,y=1:200,m_graph,axes=F,col=grey((0:256)/256),xlab=tau[j],ylab=K[i])
    }
  }
  par(mfrow=c(1,1))
}
K <- c(3,4,5)
tau <- c(0.01,0.001,0.0001)
plot(H,K,tau)


