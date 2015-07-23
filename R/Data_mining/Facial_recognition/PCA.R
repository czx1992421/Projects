#############################
# < Zhuxi Cai >
# STAT W4240 
# Homework 2 , Problem 2
# Sep,30,2014
#
# The following code aims to represent the images using PCA
#############################

library("pixmap",lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

#the list of pictures 
pic_list = 1:38
view_list = c(  'P00A+000E+00', 'P00A+005E+10' , 'P00A+005E-10' , 'P00A+010E+00')

#get directory structure
dir_list_1 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE)
dir_list_2 = dir(path="/Users/Jovial/Desktop/CroppedYale/",all.files=FALSE,recursive=TRUE)

#################
# # Problem 2a
#################
faces_matrix = vector()
for ( i in 1:length(pic_list) ){
    this_face_column = vector()
    for ( j in 1:length(view_list) ){
       this_filename = sprintf("/Users/Jovial/Desktop/CroppedYale/%s/%s_%s.pgm", dir_list_1[pic_list[i]] , dir_list_1[pic_list[i]] , view_list[j])
       this_face = read.pnm(file = this_filename) #read the pictures
       this_face_matrix = getChannels(this_face) #transfer picture into matrix
       this_face_vector = as.vector(this_face_matrix) #transfer matrix into vector
       this_face_column = rbind( this_face_column , this_face_vector ) #combine the four pictures in a subject
     }
   faces_matrix = rbind( faces_matrix , this_face_column )  #combine the pictures from different subjects
}
dim(faces_matrix) #calculate the dimension of matrix

#################
# # Problem 2b
#################
face_mean = colMeans(faces_matrix) #calculate the average for each pixel
faces_matrix_off = scale(faces_matrix,center=TRUE,scale=FALSE) #center the original faces
face_01 = read.pnm(file="/Users/Jovial/Desktop/CroppedYale/yaleB01/yaleB01_P00A-005E+10.pgm")
face_01_matrix = getChannels(face_01)
original.dimensions = dim(face_01_matrix) #get the dimension of a picture
dim(face_mean) = original.dimensions #transfer vector back into matrix
face_mean = pixmapGrey( face_mean ) #transfer matrix back into picture
plot(face_mean)

#################
# # Problem 2c
#################
pr<-prcomp(faces_matrix_off,scale=TRUE) #find the principal components of image matrix
pr_var = pr$sdev^2 
pve = pr_var/sum(pr_var) #calculate the proportion of variance
plot(pve,xlab='Number of component',ylab='Proportion of variance explained',ylim=c(0,1),type='b')

#################
# # Problem 2d
#################
eigenfaces_matrix = (pr$x)%*%t(pr$rotation) #calculate the eigenfaces matrix
nineeigenfaces_matrix = eigenfaces[1:9,] #choose the first 9 eigenfaces
picture_matrix = vector()
for ( i in 0:2 ){
    this_face_row = vector()
    for ( j in (1+3*i):(3+3*i) ){
        this_face_matrix = nineeigenfaces_matrix[j,]
        dim( this_face_matrix ) = original.dimensions 
        this_face_row = cbind( this_face_row , this_face_matrix )
    }
    picture_matrix = rbind( picture_matrix , this_face_row )  
} #put 9 eigenfaces in a 3-by-3 grid
picture = pixmapGrey(picture_matrix) #transfer matrix into picture
plot(picture)

#################
# # Problem 2e
#################
face_mean = getChannels(face_mean) #transfer picture into matrix
pr = prcomp(faces_matrix_off,center=TRUE,scale=FALSE) #find the principal components of centered image
pr$rotation = cbind(matrix(0,32256,1),pr$rotation)
pr$x = cbind(matrix(0,152,1),pr$x)
picture_matrix = vector()
this_face_matrix = face_mean
for ( i in 0:4 ){
    this_face_row =  vector()
    for ( j in (1+5*i):(5+5*i) ){
      eigenface_matrix = (pr$x[4,j])*t(pr$rotation[,j])
      eigenface_matrix = as.vector(eigenface_matrix)
      dim(eigenface_matrix) = original.dimensions
      this_face_matrix = this_face_matrix + eigenface_matrix 
      this_face_row = cbind( this_face_row , this_face_matrix )
    }
    picture_matrix = rbind( picture_matrix , this_face_row )  
} #reconstruct the image with 24 eigenfaces and put in a 5-by-5 grid
picture = pixmapGrey(picture_matrix)
plot(picture)

picture_matrix = vector()
this_face_matrix = face_mean
for ( i in seq(0,20,5) ){
  this_face_row =  vector()
  for ( j in seq(1+5*i,21+5*i,5)){
    eigenface_matrix1 = (pr$x[4,j])*t(pr$rotation[,j])
    eigenface_matrix2 = (pr$x[4,j+1])*t(pr$rotation[,j+1])
    eigenface_matrix3 = (pr$x[4,j+2])*t(pr$rotation[,j+2])
    eigenface_matrix4 = (pr$x[4,j+3])*t(pr$rotation[,j+3])
    eigenface_matrix5 = (pr$x[4,j+4])*t(pr$rotation[,j+4])
    eigenface_matrix1 = as.vector(eigenface_matrix1)
    eigenface_matrix2 = as.vector(eigenface_matrix2)
    eigenface_matrix3 = as.vector(eigenface_matrix3)
    eigenface_matrix4 = as.vector(eigenface_matrix4)
    eigenface_matrix5 = as.vector(eigenface_matrix5)
    dim(eigenface_matrix1) = original.dimensions
    dim(eigenface_matrix2) = original.dimensions
    dim(eigenface_matrix3) = original.dimensions
    dim(eigenface_matrix4) = original.dimensions
    dim(eigenface_matrix5) = original.dimensions
    this_face_matrix = this_face_matrix + eigenface_matrix1 + eigenface_matrix2 + eigenface_matrix3 + eigenface_matrix4 + eigenface_matrix5 
    this_face_row = cbind( this_face_row , this_face_matrix )
  }
  picture_matrix = rbind( picture_matrix , this_face_row )  
} #reconstruct the image with 120 eigenfaces and put in a 5-by-5 grid
picture = pixmapGrey(picture_matrix)
plot(picture)

#################
# # Problem 2f
#################
faces_matrix_removed = faces_matrix[-(17:20),] #remove the pictures of subject 5
faces_matrix_off_removed = scale(faces_matrix_removed,center=TRUE,scale=FALSE) #recenter the data
pr = prcomp(faces_matrix_off_removed,scale=TRUE) #get new principal components
score_matrix = faces_matrix_off[20,]%*%(pr$rotation) #get the score of picture
reconstruct_matrix = score_matrix%*%t(pr$rotation) #get the matrix of the reconstruct image
dim(reconstruct_matrix) = original.dimensions
reconstruct_picture = pixmapGrey(reconstruct_matrix)
plot(reconstruct_picture)
original_picture = read.pnm(file="/Users/Jovial/Desktop/CroppedYale/yaleB05/yaleB05_P00A+010E+00.pgm")
plot(original_picture) #print the original image in order to compare

#################
# # End of Script
#################