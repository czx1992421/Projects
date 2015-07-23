#############################
# Zhuxi Cai
# STAT W4240 
# Homework 4, Problem 1 
# < Homework Due Date >
#
# The following code implements an authorship attribution algorithm 
# for the Federalist dataset using a Naive Bayes classifier
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
# Problem 1a
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

#################
# Problem 1b
#################

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

#################
# Problem 1c
#################

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

#################
# Problem 1d
#################

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
# Problem 1e
#################

##########################################
make.log.pvec <- function(dtm,mu){
    # Sum up the number of instances per word
    pvec.no.mu <- colSums(dtm)
    # Sum up number of words
    n.words <- sum(pvec.no.mu)
    # Get dictionary size
    dic.len <- length(pvec.no.mu)
    # Incorporate mu and normalize
    log.pvec <- log(pvec.no.mu + mu) - log(mu*dic.len + n.words)
    return(log.pvec)
}
D = nrow(dictionary)
logp.hamilton.train = make.log.pvec(dtm.hamilton.train, 100/D)
logp.hamilton.test = make.log.pvec(dtm.hamilton.test, 100/D)
logp.madison.train = make.log.pvec(dtm.madison.train, 100/D)
logp.madison.test = make.log.pvec(dtm.madison.test, 100/D)
##########################################

#################
# Problem 2
#################
# Write a function to compute log probability and assign authorship to a test paper
result = vector()
naive.bayes = function(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.test){
  n = nrow(dtm.test)
  for (i in 1:n) {
    logp.hamilton = log.prior.hamilton + dtm.test %*% logp.hamilton.train
    logp.madison = log.prior.madison + dtm.test %*% logp.madison.train
    if (logp.hamilton[i] > logp.madison[i]) result[i]=1
    else result[i]=0
  }
  result
}

#################
# Problem 3
#################
# Calculate the percentage of test papers which are classified correctly
log.prior.hamilton = log(length(hamilton.train)/(length(hamilton.train)+length(madison.train)))
log.prior.madison = log(length(madison.train)/(length(hamilton.train)+length(madison.train)))
classification.hamilton = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.hamilton.test)
classification.madison = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.madison.test)
classification.hamilton
classification.madison
# Report several proportions
proportion.true.positive = sum(classification.hamilton)/length(classification.hamilton)
proportion.false.positive = sum(classification.madison)/length(classification.madison)
proportion.true.negative = 1-proportion.false.positive
proportion.false.negative = 1-proportion.true.positive

#################
# Problem 4a
#################
# For each value of tunable parameter mu, report several rates using 5-fold cross-validation on the training set
set.seed(2)
x = 1:35
index1 = sample(x,7)
index2 = sample(x[-index1],7)
index3 = sample(x[-rbind(index1,index2)],7)
index4 = sample(x[-rbind(index1,index2,index3)],7)
index5 = x[-rbind(index1,index2,index3,index4)]
index_hamilton = cbind(index1,index2,index3,index4,index5)
y = 1:15
index11 = sample(y,3)
index22 = sample(y[-index11],3)
index33 = sample(y[-rbind(index11,index22)],3)
index44 = sample(y[-rbind(index11,index22,index33)],3)
index55 = y[-rbind(index11,index22,index33,index44)]
index_madison = cbind(index11,index22,index33,index44,index55)
mu = c(1/D,10/D,100/D,1000/D,10000/D)
correct_matrix = matrix(0,5,5)
falseneg_matrix = matrix(0,5,5)
falsepos_matrix = matrix(0,5,5)
dtm.hamilton = make.document.term.matrix(hamilton.train, dictionary)
dtm.madison = make.document.term.matrix(madison.train, dictionary)
for (m in 1:5){
  dtm.hamilton.train = dtm.hamilton[-index_hamilton[,m],]
  dtm.madison.train = dtm.madison[-index_madison[,m],]
  dtm.hamilton.test = dtm.hamilton[index_hamilton[,m],]
  dtm.madison.test = dtm.madison[index_madison[,m],]
  for(n in 1:5){
    logp.hamilton.train = make.log.pvec(dtm.hamilton.train, mu[n])
    logp.madison.train = make.log.pvec(dtm.madison.train, mu[n])
    classification.hamilton = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.hamilton.test)
    classification.madison = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.madison.test)
    correct_matrix[n,m] = (sum(classification.hamilton)+length(classification.madison)-sum(classification.madison))/(length(classification.hamilton)+length(classification.madison))
    falseneg_matrix[n,m] = 1-sum(classification.hamilton)/length(classification.hamilton)
    falsepos_matrix[n,m] = sum(classification.madison)/length(classification.madison)
  }
}
correct_matrix_1 = rowMeans(correct_matrix)
falseneg_matrix_1 = rowMeans(falseneg_matrix)
falsepos_matrix_1 = rowMeans(falsepos_matrix)
logmu = log(mu)
plot(correct_matrix_1~logmu,type='b',main='Correct Classification Rate',xlab='mu',ylab='correct classification rate')
plot(falseneg_matrix_1~logmu,type='b',main='False Negative Rate',xlab='mu',ylab='false negtive rate')
plot(falsepos_matrix_1~logmu,type='b',main='False Positive Rate',xlab='mu',ylab='false positive rate')

#################
# Problem 4c
#################
# For each value of mu, train on the full training set and test on the full testing set
dtm.hamilton.test = make.document.term.matrix(hamilton.test, dictionary)
dtm.madison.test = make.document.term.matrix(madison.test, dictionary)
correct_vector = rep(0,5)
falseneg_vector = rep(0,5)
falsepos_vector = rep(0,5)
for(i in 1:5){
  logp.hamilton.train = make.log.pvec(dtm.hamilton, mu[i])
  logp.madison.train = make.log.pvec(dtm.madison, mu[i])
  classification.hamilton = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.hamilton.test)
  classification.madison = naive.bayes(logp.hamilton.train,logp.madison.train,log.prior.hamilton,log.prior.madison,dtm.madison.test)
  correct_vector[i] = (sum(classification.hamilton)+length(classification.madison)-sum(classification.madison))/(length(classification.hamilton)+length(classification.madison))
  falseneg_vector[i] = 1-sum(classification.hamilton)/length(classification.hamilton)
  falsepos_vector[i] = sum(classification.madison)/length(classification.madison)
}
plot(correct_vector~logmu,type='b',main='Correct Classification Rate',xlab='mu',ylab='correct classification rate')
plot(falseneg_vector~logmu,type='b',main='False Negative Rate',xlab='mu',ylab='false negtive rate')
plot(falsepos_vector~logmu,type='b',main='False Positive Rate',xlab='mu',ylab='false positive rate')

#################
# Problem 4d
#################
# Calculate the differences between the cross-validation rate estimates and the rates on the training sets
error_percentage = rep(0,5)
for (j in 1:5){
  error_percentage[j] = abs(correct_matrix_1[j]-correct_vector[j])/correct_vector[j]
}

#################
# End of Script
#################


