#############################
# <Zhuxi Cai>
# STAT W4240 
# Homework 3, Problem 4
# Oct 14, 2014
#
# The following code uses 1NN classification and PCA to do facial recognition
#############################

#################
# Setup
#################

# make sure R is in the proper working directory
# note that this will be a different path for every machine
# first include the relevant libraries
# note that a loading error might mean that you have to
# install the package into your R distribution.  
library("pixmap", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

#################
# Problem 4a
#################

# load the data and save it as a matrix with the name face_matrix_4a
#the list of pictures 
pic_list = 1:38
views_4a = c('P00A+000E+00', 'P00A+005E+10', 'P00A+005E-10', 'P00A+010E+00' )
#get directory structure
dir_list_1 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE)
dir_list_2 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE,recursive=TRUE)
face_matrix_4a = vector()
for ( i in 1:length(pic_list) ){
  this_face_column = vector()
  for ( j in 1:length(views_4a) ){
    this_filename = sprintf("/Users/Jovial/Desktop/CroppedYale/%s/%s_%s.pgm", dir_list_1[pic_list[i]] , dir_list_1[pic_list[i]] , views_4a[j])
    this_face = read.pnm(file = this_filename) #read the pictures
    this_face_matrix = getChannels(this_face) #transfer picture into matrix
    this_face_vector = as.vector(this_face_matrix) #transfer matrix into vector
    this_face_vector = c(this_face_vector,i)
    this_face_column = rbind( this_face_column , this_face_vector ) #combine the four pictures in a subject
  }
  face_matrix_4a = rbind( face_matrix_4a , this_face_column )  #combine the pictures from different subjects
}
# Get the size of the matrix for use later
fm_4a_size = dim(face_matrix_4a)
# Use 4/5 of the data for training, 1/5 for testing
ntrain_4a = floor(fm_4a_size[1]*4/5) # Number of training obs
ntest_4a = fm_4a_size[1]-ntrain_4a # Number of testing obs
set.seed(1) # Set pseudo-random numbers so everyone gets the same output
ind_train_4a = sample(1:fm_4a_size[1],ntrain_4a) # Training indices
ind_test_4a = c(1:fm_4a_size[1])[-ind_train_4a] # Testing indices

#################
# Problem 4b
#################

face_lable = face_matrix_4a[,32257] #lable the subject name
face_lable_train = face_lable[ind_train_4a] #lable the training set
face_lable_test = face_lable[ind_test_4a] #lable the testing set
face_matrix_4a = face_matrix_4a[,-32257]
face_matrix_train = face_matrix_4a[ind_train_4a,] #get the training matrix
face_train_off = scale(face_matrix_train,center=TRUE,scale=FALSE) #center the training matrix
pr = prcomp(face_train_off,scale=FALSE) #find the principal components of training matrix
score_train = pr$x[,1:25] #get the first 25 scores of training set
loading_train = pr$rotation[,1:25] #get the first 25 loadings of traing set
face_matrix_test = face_matrix_4a[ind_test_4a,] #get the testing matrix
face_mean = colMeans(face_matrix_train) 
face_test_off = t(t(face_matrix_test)-face_mean) #center the testing matrix
score_test = face_test_off%*%loading_train #get the first 25 scores of testing set
knn(score_train,score_test,face_lable_train,k=1,prob=TRUE,use.all=TRUE) #make kNN classificaiton

#################
# Problem 4c
#################

# Use different lighting conditions
views_4c = c('P00A-035E+15', 'P00A-050E+00', 'P00A+035E+15', 'P00A+050E+00')
# load your data and save the images as face_matrix_4c
#get directory structure
dir_list_1 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE)
dir_list_2 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE,recursive=TRUE)
face_matrix_4c = vector()
for ( i in 1:length(pic_list) ){
  this_face_column = vector()
  for ( j in 1:length(views_4c) ){
    this_filename = sprintf("/Users/Jovial/Desktop/CroppedYale/%s/%s_%s.pgm", dir_list_1[pic_list[i]] , dir_list_1[pic_list[i]] , views_4c[j])
    this_face = read.pnm(file = this_filename) #read the pictures
    this_face_matrix = getChannels(this_face) #transfer picture into matrix
    this_face_vector = as.vector(this_face_matrix) #transfer matrix into vector
    this_face_vector = c(this_face_vector,i)
    this_face_column = rbind( this_face_column , this_face_vector ) #combine the four pictures in a subject
  }
  face_matrix_4c = rbind( face_matrix_4c , this_face_column )  #combine the pictures from different subjects
}
fm_4c_size = dim(face_matrix_4c)
# Use 4/5 of the data for training, 1/5 for testing
ntrain_4c = floor(fm_4c_size[1]*4/5)
ntest_4c = fm_4c_size[1]-ntrain_4c
set.seed(2) # Set pseudo-random numbers
# You are resetting so that if you have used a random number in between the last use of sample(), you will still get the same output
ind_train_4c = sample(1:fm_4c_size[1],ntrain_4c)
ind_test_4c = c(1:fm_4c_size[1])[-ind_train_4c]
#The same as problem 4b
face_lable = face_matrix_4c[,32257]
face_lable_train = face_lable[ind_train_4c]
face_lable_test = face_lable[ind_test_4c]
face_matrix_4c = face_matrix_4c[,-32257]
face_matrix_train = face_matrix_4c[ind_train_4c,]
face_train_off = scale(face_matrix_train,center=TRUE,scale=FALSE)
pr = prcomp(face_train_off,scale=FALSE) 
score_train = pr$x[,1:25]
loading_train = pr$rotation[,1:25]
face_matrix_test = face_matrix_4c[ind_test_4c,]
face_mean = colMeans(face_matrix_train)
face_test_off = t(t(face_matrix_test)-face_mean)
score_test = face_test_off%*%loading_train
knn(score_train,score_test,face_lable_train,k=1,prob=TRUE,use.all=TRUE)
lable_knn = c(3,2,33,10,7,8,8,27,19,10,22,6,7,11,22,17,17,6,6,19,29,22,10,4,31,33,35,32,8,33,37)
as.numeric(face_lable_test == lable_knn)
#plot 27 subject photos that are misidentified next to the 1NN photo prediction
face_matrix_output = vector()
for ( m in 1:31 ){
  face_matrix_original = face_matrix_4c[ind_test_4c[m],]
  n = ind_test_4c[m]%%4
  face_matrix_prediction = face_matrix_4c[4*lable_knn[m]-n,]
  face_matrix_comparison = rbind(face_matrix_prediction,face_matrix_original)
  face_matrix_output = rbind(face_matrix_output,face_matrix_comparison)
} #pick up the photos in the original matrix
face_matrix_output = face_matrix_output[-c(3,4,29,30,49,50,61,62),] #deliminate identified pairs
face_01 = read.pnm(file="/Users/Jovial/Desktop/CroppedYale/yaleB01/yaleB01_P00A-005E+10.pgm")
face_01_matrix = getChannels(face_01)
original.dimensions = dim(face_01_matrix)
#arrange plots as 9*6
picture_matrix_whole = vector()
for ( a in 1:9 ){
    picture_matrix_row = vector()
    for (b in (6*a-5):(6*a)){
      picture_matrix = face_matrix_output[b,]
      dim(picture_matrix) = original.dimensions
      picture_matrix_row = cbind(picture_matrix_row,picture_matrix)
    }
    picture_matrix_whole = rbind(picture_matrix_whole,picture_matrix_row)
}
picture_matrix_whole = pixmapGrey(picture_matrix_whole)
plot(picture_matrix_whole)

#################
# Problem 4d
#################

#change the number of set.seed and repeat problem 4c for 10 times
# Use different lighting conditions
pic_list = 1:38
views_4c = c('P00A-035E+15', 'P00A-050E+00', 'P00A+035E+15', 'P00A+050E+00')
# load your data and save the images as face_matrix_4c
#get directory structure
dir_list_1 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE)
dir_list_2 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE,recursive=TRUE)
face_matrix_4c = vector()
for ( i in 1:length(pic_list) ){
  this_face_column = vector()
  for ( j in 1:length(views_4c) ){
    this_filename = sprintf("/Users/Jovial/Desktop/CroppedYale/%s/%s_%s.pgm", dir_list_1[pic_list[i]] , dir_list_1[pic_list[i]] , views_4c[j])
    this_face = read.pnm(file = this_filename) #read the pictures
    this_face_matrix = getChannels(this_face) #transfer picture into matrix
    this_face_vector = as.vector(this_face_matrix) #transfer matrix into vector
    this_face_vector = c(this_face_vector,i)
    this_face_column = rbind( this_face_column , this_face_vector ) #combine the four pictures in a subject
  }
  face_matrix_4c = rbind( face_matrix_4c , this_face_column )  #combine the pictures from different subjects
}
fm_4c_size = dim(face_matrix_4c)
# Use 4/5 of the data for training, 1/5 for testing
ntrain_4c = floor(fm_4c_size[1]*4/5)
ntest_4c = fm_4c_size[1]-ntrain_4c
set.seed(1) # Set pseudo-random numbers
# You are resetting so that if you have used a random number in between the last use of sample(), you will still get the same output
ind_train_4c = sample(1:fm_4c_size[1],ntrain_4c)
ind_test_4c = c(1:fm_4c_size[1])[-ind_train_4c]
face_lable = face_matrix_4c[,32257]
face_lable_train = face_lable[ind_train_4c]
face_lable_test = face_lable[ind_test_4c]
face_matrix_4c = face_matrix_4c[,-32257]
face_matrix_train = face_matrix_4c[ind_train_4c,]
face_train_off = scale(face_matrix_train,center=TRUE,scale=FALSE)
pr = prcomp(face_train_off,scale=FALSE) 
score_train = pr$x[,1:25]
loading_train = pr$rotation[,1:25]
face_matrix_test = face_matrix_4c[ind_test_4c,]
face_mean = colMeans(face_matrix_train)
face_test_off = t(t(face_matrix_test)-face_mean)
score_test = face_test_off%*%loading_train
lable_knn = as.vector(knn(score_train,score_test,face_lable_train,k=1,prob=TRUE,use.all=TRUE))
as.numeric(face_lable_test == lable_knn)
this_filename = sprintf("/Users/Jovial/Desktop/CroppedYale/yaleB01/yaleB01_P00A+050E+00.pgm")
this_face = read.pnm(file = this_filename)
this_face_matrix = getChannels(this_face)
this_face_matrix = pixmapGrey( this_face_matrix )
plot(this_face_matrix)

