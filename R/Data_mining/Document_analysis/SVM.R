#############################
# < Zhuxi Cai >
# STAT W4240 
# Homework 06 
# < 8 Dec >
#
# The following code uses SVM to implement the classification
#############################

#################
# Setup
#################

# make sure R is in the proper working directory
# note that this will be a different path for every machine
setwd("~/Desktop/hw04")

# first include the relevant libraries
# note that a loading error might mean that you have to
# install the package into your R distribution.
# Use the package installer and be sure to install all dependencies
library(tm)
library(SnowballC)

#################
# Read in the Federalist Papers and create document term matrices
#################

##########################################
# This code uses tm to preprocess the papers into a format useful for NB
preprocess.directory = function(dirname){
  
  # the directory must have all the relevant text files
  ds = DirSource(dirname)
  # Corpus will make a tm document corpus from this directory
  fp = Corpus( ds )
  # inspect to verify
  # inspect(fp[1])
  # another useful command
  # identical(fp[[1]], fp[["Federalist01.txt"]])
  # now let us iterate through and clean this up using tm functionality
  # make all words lower case
  fp = tm_map( fp , content_transformer(tolower));
  # remove all punctuation
  fp = tm_map( fp , removePunctuation);
  # remove stopwords like the, a, and so on.  
  fp = tm_map( fp , removeWords, stopwords("english"));
  # remove stems like suffixes
  fp = tm_map( fp , stemDocument)
  # remove extra whitespace
  fp = tm_map( fp , stripWhitespace)	
  # now write the corpus out to the files for our future use.
  # MAKE SURE THE _CLEAN DIRECTORY EXISTS
  writeCorpus( fp , sprintf('%s_clean',dirname) , filenames = names(fp))
}
preprocess.directory("fp_hamilton_train")
preprocess.directory("fp_hamilton_test")
preprocess.directory("fp_madison_train")
preprocess.directory("fp_madison_test")
##########################################

##########################################
# To read in data from the directories:
# Partially based on code from C. Shalizi
read.directory <- function(dirname) {
  # Store the infiles in a list
  infiles = list();
  # Get a list of filenames in the directory
  filenames = dir(dirname,full.names=TRUE);
  for (i in 1:length(filenames)){
    infiles[[i]] = scan(filenames[i],what="",quiet=TRUE);
  }
  return(infiles)
}
hamilton.train = read.directory("fp_hamilton_train_clean")
hamilton.test = read.directory("fp_hamilton_test_clean")
madison.train = read.directory("fp_madison_train_clean")
madison.test = read.directory("fp_madison_test_clean")
##########################################

##########################################
# Make dictionary sorted by number of times a word appears in corpus 
# (useful for using commonly appearing words as factors)
# NOTE: Use the *entire* corpus: training, testing, spam and ham
make.sorted.dictionary.df <- function(infiles){
  # This returns a dataframe that is sorted by the number of times 
  # a word appears
  
  # List of vectors to one big vetor
  dictionary.full <- unlist(infiles) 
  # Tabulates the full dictionary
  tabulate.dic <- tabulate(factor(dictionary.full)) 
  # Find unique values
  dictionary <- unique(dictionary.full) 
  # Sort them alphabetically
  dictionary <- sort(dictionary)
  dictionary.df <- data.frame(word = dictionary, count = tabulate.dic)
  sort.dictionary.df <- dictionary.df[order(dictionary.df$count,decreasing=TRUE),];
  return(sort.dictionary.df)
}
rbind_matrix = rbind(hamilton.train, hamilton.test, madison.train, madison.test)
dictionary = make.sorted.dictionary.df(rbind_matrix)
##########################################

##########################################
# Make a document-term matrix, which counts the number of times each 
# dictionary element is used in a document
make.document.term.matrix <- function(infiles,dictionary){
  # This takes the text and dictionary objects from above and outputs a 
  # document term matrix
  num.infiles <- length(infiles);
  num.words <- nrow(dictionary);
  # Instantiate a matrix where rows are documents and columns are words
  dtm <- mat.or.vec(num.infiles,num.words); # A matrix filled with zeros
  for (i in 1:num.infiles){
    num.words.infile <- length(infiles[[i]]);
    infile.temp <- infiles[[i]];
    for (j in 1:num.words.infile){
      ind <- which(dictionary == infile.temp[j])[[1]];
      # print(sprintf('%s,%s', i , ind))
      dtm[i,ind] <- dtm[i,ind] + 1;
    }
  }
  return(dtm);
}
dtm.hamilton.train = make.document.term.matrix(hamilton.train, dictionary)
dtm.hamilton.test = make.document.term.matrix(hamilton.test, dictionary)
dtm.madison.train = make.document.term.matrix(madison.train, dictionary)
dtm.madison.test = make.document.term.matrix(madison.test, dictionary)
##########################################

#Make training and test sets
dat.train = as.data.frame(rbind(dtm.hamilton.train,dtm.madison.train))
dat.test = as.data.frame(rbind(dtm.hamilton.test,dtm.madison.test))
names(dat.train) = names(dat.test) = as.vector(dictionary$word)
dat.train$y = as.factor(c(rep(1,nrow(dtm.hamilton.train)),rep(0,nrow(dtm.madison.train))))
dat.test$y = as.factor(c(rep(1,nrow(dtm.hamilton.test)),rep(0,nrow(dtm.madison.test))))
#Center and scale the data
mean.train = apply(dat.train[,-4876],2,mean)
sd.train = apply(dat.train[,-4876],2,sd)
x.train = scale(dat.train[,-4876])
x.train[,sd.train==0] = 0
x.test = scale(dat.test[,-4876],center=mean.train,scale=sd.train)
x.test[,sd.train==0] = 0
y.train = dat.train$y
y.test = dat.test$y

#################
# Problem 4a
#################
#Fit an SVM with a linear kernel to the training data
fit.svm = svm(x.train[,c(1:100)],y.train,kernel="linear",scale=FALSE)
pred.svm = predict(fit.svm,x.test[,c(1:100)])
comparison = as.numeric(pred.svm == dat.test[,4876])
proportion.classification.svm = sum(comparison)/length(comparison)
proportion.classification.svm

#################
# Problem 4b
#################
#Plot the classification performance as a function of the number of words
number = seq(5,100,5)
proportion.classification.svm = rep(0,length(number))
proportion.false.negatives.svm = rep(0,length(number))
proportion.false.positives.svm = rep(0,length(number))
j = 0
for (i in number){
  j = j+1
  fit.svm = svm(x.train[,c(1:number[j])],y.train,kernel="linear",scale=FALSE)
  pred.svm = predict(fit.svm,x.test[,c(1:number[j])])
  comparison = as.numeric(pred.svm == dat.test[,4876])
  proportion.classification.svm[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.svm[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.svm[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
proportion.classification.matrix = t(rbind(proportion.classification.svm,proportion.false.negatives.svm,proportion.false.positives.svm))
matplot(x=number,y=proportion.classification.matrix,type="l",lty=1:3,col=1:3,lwd=c(3,3,3),xlim=c(0,110),ylim=c(0,1),main="Classification performance",xlab="Number of words",ylab="Proportion")
legend(70,0.7,cex=0.7,c("Correct classification","False negatives","False positives"),lty=1:3,col=1:3)

#################
# Problem 4c
#################
#Fit an SVM with an RBF kernel
number = seq(5,100,5)
proportion.classification.svm = rep(0,length(number))
proportion.false.negatives.svm = rep(0,length(number))
proportion.false.positives.svm = rep(0,length(number))
j = 0
for (i in number){
  j = j+1
  fit.svm = svm(x.train[,c(1:number[j])],y.train,kernel="radial",scale=FALSE)
  pred.svm = predict(fit.svm,x.test[,c(1:number[j])])
  comparison = as.numeric(pred.svm == dat.test[,4876])
  proportion.classification.svm[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.svm[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.svm[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
proportion.classification.matrix = t(rbind(proportion.classification.svm,proportion.false.negatives.svm,proportion.false.positives.svm))
matplot(x=number,y=proportion.classification.matrix,type="l",lty=1:3,col=1:3,lwd=c(3,3,3),xlim=c(0,110),ylim=c(0,1),main="Classification performance",xlab="Number of words",ylab="Proportion")
legend(70,0.4,cex=0.7,c("Correct classification","False negatives","False positives"),lty=1:3,col=1:3)

#################
# Problem 4d
#################
#Classify authorship based on the top two features
row.names = as.numeric(row.names(dictionary.new)[c(1,2)])
dat.train.new = data.frame(x=x.train[,row.names],y=as.factor(dat.train$y))
fit.svm.top1 = svm(y~.,data=dat.train.new,kernel="radial",cost=1,scale=FALSE)
plot(fit.svm.top1,dat.train.new)
fit.svm.top2 = svm(y~.,data=dat.train.new,kernel="radial",cost=10000,scale=FALSE)
plot(fit.svm.top2,dat.train.new)
tune.out=tune(svm,y~.,data=dat.train.new,kernel="radial",ranges=list(cost=c(0.001,0.01,0.1,1,5,10,100,500,1000)))
summary(tune.out)
fit.svm.top3 = svm(y~.,data=dat.train.new,kernel="radial",cost=100,scale=FALSE)
plot(fit.svm.top3,dat.train.new)
