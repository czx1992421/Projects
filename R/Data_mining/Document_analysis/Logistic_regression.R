#############################
# < Zhuxi Cai >
# STAT W4240 
# Homework 05 
# < 25 Nov >
#
# The following code uses regularized logistic regression to classify the Federalist Papers
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
# Problem 7b
#################
# Create centered and scaled version of document term matrices
lable.train.matrix = train.matrix[,4876]
train.matrix.reg = scale(train.matrix[,-4876],center=T,scale=T)
train.matrix.reg = cbind(train.matrix.reg,lable.train.matrix)
lable.test.matrix = test.matrix[,4876]
test.matrix.reg = scale(test.matrix[,-4876],center=T,scale=T)
test.matrix.reg = cbind(test.matrix.reg,lable.test.matrix)
name.vector = c(as.vector(dictionary$word),"y")
colnames(train.matrix.reg) = name.vector
colnames(test.matrix.reg) = name.vector

# fit a ridge regression model
train.matrix.reg[is.nan(train.matrix.reg)]=0
test.matrix.reg[is.nan(test.matrix.reg)]=0
set.seed(2)
fit1 = cv.glmnet(train.matrix.reg[,-4876],as.matrix(train.matrix.reg[,4876]),family='binomial',alpha=0)
# Apply the model to the testing data
prediction1 = predict(fit1,test.matrix.reg[,-4876],type='class')
# Compare the prediction and testing data
comparison1 = as.numeric(prediction1 == test.matrix.reg[,4876])
# Compute the proportions
proportion.classification1 = sum(comparison1)/length(comparison1)
proportion.false.negatives1 = 1-sum(comparison1[1:16])/length(comparison1[1:16])
proportion.false.positives1 = 1-sum(comparison1[17:27])/length(comparison1[17:27])
# Find the most important words
words1=colnames(train.matrix.reg)[order(abs(coef(fit1)[-4876]),decreasing=T)][1:10]
weights1=sort(abs(coef(fit1)[-4876]),decreasing=T)[1:10]
result1=cbind(words1,weights1)
result1  

#################
# Problem 7c
#################
# fit a lasso regression model
set.seed(2)
fit2 = cv.glmnet(train.matrix.reg[,-4876],as.matrix(train.matrix.reg[,4876]),family='binomial',alpha=1)
# Apply the model to the testing data
prediction2 = predict(fit2,test.matrix.reg[,-4876],type='class')
# Compare the prediction and testing data
comparison2 = as.numeric(prediction2 == test.matrix.reg[,4876])
# Compute the proportions
proportion.classification2 = sum(comparison2)/length(comparison2)
proportion.false.negatives2 = 1-sum(comparison2[1:16])/length(comparison2[1:16])
proportion.false.positives2 = 1-sum(comparison2[17:27])/length(comparison2[17:27])
# Find the most important words
words2=colnames(train.matrix.reg)[order(abs(coef(fit2)[-4876]),decreasing=T)][1:10]
weights2=sort(abs(coef(fit2)[-4876]),decreasing=T)[1:10]
result2=cbind(words2,weights2)
result2