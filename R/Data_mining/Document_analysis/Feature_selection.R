#############################
# < Zhuxi Cai >
# STAT W4240 
# Homework 06 
# < 8 Dec >
#
# The following code uses feature selection to remove features that are irrelevant to classification
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

#################
# Problem 3b
#################
#Compute the mutual information for all features
hamilton.train.dat = as.data.frame(dtm.hamilton.train)
madison.train.dat = as.data.frame(dtm.madison.train)
names(hamilton.train.dat) = names(madison.train.dat) = as.vector(dictionary$word)
train.dat = rbind(hamilton.train.dat,madison.train.dat)
p.hamilton.feature = colSums(hamilton.train.dat)/sum(hamilton.train.dat)
p.madison.feature = colSums(madison.train.dat)/sum(madison.train.dat)
p.feature = colSums(train.dat)/sum(train.dat)
p.hamilton = nrow(hamilton.train.dat)/nrow(train.dat)
p.madison = nrow(madison.train.dat)/nrow(train.dat)
I.hamilton = p.hamilton.feature*p.hamilton*log(p.hamilton.feature/p.feature)+(1-p.hamilton.feature)*p.hamilton*log((1-p.hamilton.feature)/(1-p.feature))
I.madison = p.madison.feature*p.madison*log(p.madison.feature/p.feature)+(1-p.madison.feature)*p.madison*log((1-p.madison.feature)/(1-p.feature))
I = I.hamilton + I.madison
I[is.na(I)==1]=0
#Make new dictionary
I.dat = as.data.frame(I)
train.matrix.feature = as.data.frame(data.frame(dictionary$word,I.dat,row.names=c(1:4875)))
dictionary.new = train.matrix.feature[order(-train.matrix.feature$I),]
#Make new document-term matrix
dtm.hamilton.train.new = make.document.term.matrix(hamilton.train, dictionary.new)
dtm.hamilton.test.new = make.document.term.matrix(hamilton.test, dictionary.new)
dtm.madison.train.new = make.document.term.matrix(madison.train, dictionary.new)
dtm.madison.test.new = make.document.term.matrix(madison.test, dictionary.new)
train.dat.new = as.data.frame(rbind(dtm.hamilton.train.new,dtm.madison.train.new))
test.dat.new = as.data.frame(rbind(dtm.hamilton.test.new,dtm.madison.test.new))
names(train.dat.new) = names(test.dat.new) = as.vector(dictionary.new$dictionary.word)
train.dat.new$y = as.factor(c(rep(1,nrow(dtm.hamilton.train)),rep(0,nrow(dtm.madison.train))))
test.dat.new$y = as.factor(c(rep(1,nrow(dtm.hamilton.test)),rep(0,nrow(dtm.madison.test))))
#Tree classification with Gini splits
proportion.classification.tree.gini = rep(0,4)
proportion.false.negatives.tree.gini = rep(0,4)
proportion.false.positives.tree.gini = rep(0,4)
j=0
for (i in c(200,500,1000,2500)){
  j=j+1
  tree.gini = rpart(y~.,data=train.dat.new[,c(1:i,4876)],parms=list(split='gini'))
  pred.tree.gini = predict(tree.gini,newdata=test.dat.new,type="class")
  comparison = as.numeric(pred.tree.gini == test.dat.new[,4876])
  proportion.classification.tree.gini[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.tree.gini[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.tree.gini[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
#Tree classificaiton with information splits
proportion.classification.tree.info = rep(0,4)
proportion.false.negatives.tree.info = rep(0,4)
proportion.false.positives.tree.info = rep(0,4)
j=0
for (i in c(200,500,1000,2500)){
  j=j+1
  tree.info = rpart(y~.,data=train.dat.new[,c(1:i,4876)],parms=list(split='information'))
  pred.tree.info = predict(tree.info,newdata=test.dat.new,type="class")
  comparison = as.numeric(pred.tree.info == test.dat.new[,4876])
  proportion.classification.tree.info[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.tree.info[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.tree.info[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
#Ridge logistic regression
mean.train = apply(train.dat.new[,-4876],2,mean)
sd.train = apply(train.dat.new[,-4876],2,sd)
x.train = scale(train.dat.new[,-4876])
x.train[,sd.train==0] = 0
x.test = scale(test.dat.new[,-4876],center=mean.train,scale=sd.train)
x.test[,sd.train==0] = 0
y.train = train.dat.new$y
y.test = test.dat.new$y
proportion.classification.ridge = rep(0,4)
proportion.false.negatives.ridge = rep(0,4)
proportion.false.positives.ridge = rep(0,4)
j=0
for (i in c(200,500,1000,2500)){
  j=j+1
  fit.ridge = cv.glmnet(x.train[,c(1:i)],y.train,family='binomial',alpha=0,standardize=F)
  pred.ridge = predict(fit.ridge,newx=x.test[,c(1:i)],s="lambda.min",type="class")
  comparison = as.numeric(pred.ridge == test.dat.new[,4876])
  proportion.classification.ridge[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.ridge[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.ridge[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
#Lasso logistic regression
proportion.classification.lasso = rep(0,4)
proportion.false.negatives.lasso = rep(0,4)
proportion.false.positives.lasso = rep(0,4)
j=0
for (i in c(200,500,1000,2500)){
  j=j+1
  fit.lasso = cv.glmnet(x.train[,c(1:i)],y.train,family='binomial',alpha=1,standardize=F)
  pred.lasso = predict(fit.lasso,newx=x.test[,c(1:i)],s="lambda.min",type="class")
  comparison = as.numeric(pred.lasso == test.dat.new[,4876])
  proportion.classification.lasso[j] = sum(comparison)/length(comparison)
  proportion.false.negatives.lasso[j] = 1-sum(comparison[1:16])/length(comparison[1:16])
  proportion.false.positives.lasso[j] = 1-sum(comparison[17:27])/length(comparison[17:27])
}
#Display the results in three graphs
#The proportion classified correctly
proportion.classification.matrix = t(rbind(proportion.classification.tree.gini,proportion.classification.tree.info,proportion.classification.ridge,proportion.classification.lasso))
proportion.classification.matrix = data.frame(proportion.classification.matrix,row.names=c("200","500","1000","2500"))
names(proportion.classification.matrix) = as.vector(c("Gini tree","Info tree","Ridge regression","Lasso regression"))
proportion.classification.matrix
matplot(x=c("200","500","1000","2500"),y=proportion.classification.matrix,type="l",lty=1:4,col=1:4,lwd=c(3,3,3,3),main="Proportion classified correctly",xlab="Number of words",ylab="Proportion",ylim=c(0,1))
legend(200,0.4,cex=0.7,c("Gini","Info","Ridge","Lasso"),lty=1:4,col=1:4)
#The proportion of false negatives
proportion.false.negatives.matrix = t(rbind(proportion.false.negatives.tree.gini,proportion.false.negatives.tree.info,proportion.false.negatives.ridge,proportion.false.negatives.lasso))
proportion.false.negatives.matrix = data.frame(proportion.false.negatives.matrix,row.names=c("200","500","1000","2500"))
names(proportion.false.negatives.matrix) = as.vector(c("Gini tree","Info tree","Ridge regression","Lasso regression"))
proportion.false.negatives.matrix
matplot(x=c("200","500","1000","2500"),y=proportion.false.negatives.matrix,type="l",lty=1:4,col=1:4,lwd=c(3,3,3,3),main="Proportion of false negatives",xlab="Number of words",ylab="Proportion",ylim=c(0,1))
legend(200,1,cex=0.7,c("Gini","Info","Ridge","Lasso"),lty=1:4,col=1:4)
#The proportion of false positives
proportion.false.positives.matrix = t(rbind(proportion.false.positives.tree.gini,proportion.false.positives.tree.info,proportion.false.positives.ridge,proportion.false.positives.lasso))
proportion.false.positives.matrix = data.frame(proportion.false.positives.matrix,row.names=c("200","500","1000","2500"))
names(proportion.false.positives.matrix) = as.vector(c("Gini tree","Info tree","Ridge regression","Lasso regression"))
proportion.false.positives.matrix
matplot(x=c("200","500","1000","2500"),y=proportion.false.positives.matrix,type="l",lty=1:4,col=1:4,lwd=c(3,3,3,3),main="Proportion of false positives",xlab="Number of words",ylab="Proportion",ylim=c(0,1))
legend(200,0.8,cex=0.7,c("Gini","Info","Ridge","Lasso"),lty=1:4,col=1:4)
