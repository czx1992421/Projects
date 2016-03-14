setwd('/Users/Jovial/Desktop/4201')
data = read.csv("cleandata.csv", header = T)
data.d<-data$INSPECTION.DATE
index<-c(rep(1,nrow(data)))
for(n in 2:nrow(data)){
  if(data.d[n]==data.d[n-1])
    index[n]<-index[n-1]
  else
    index[n]<-index[n-1]+1
}

dindex<-c(rep(1,nrow(data)-range(index)[2]))
k<-1
for(n in 2:length(index)){
  if (index[n]==index[n-1]){
    dindex[k]<-n
    k<-k+1
  }
}
data.new<-cbind(data,index)
b<-tapply(rep(1,nrow(data.new)),list(data.new$index,data.new$VIOLATION.CODE),sum)
index<-c(1:nrow(b))
bb<-cbind(index,b)
cc<-as.data.frame(bb)
d3<-merge(data.new,cc,by="index")
d4<-d3[-dindex,]
d5<-d4[,-19]

date<-as.character(d5$INSPECTION.DATE)

data.n<-d5$CAMIS
index_2<-vector()
j=1
for(n in 2:length(index)){
  if (data.n[index[n]] == data.n[index[n-1]]){
    index_2[j]<-n-1
    j=j+1
  }
}
data_all<-d5[index[-index_2],]

index2015_1<-grep("2015",date,fixed=TRUE)
data.n<-d5$CAMIS
index2015_2<-vector()
j=1
for(n in 2:length(index2015_1)){
  if (data.n[index2015_1[n]] == data.n[index2015_1[n-1]]){
    index2015_2[j]<-n-1
    j=j+1
  }
}
data_2015<-d5[index2015_1[-index2015_2],]

index2014_1<-grep("2014",date,fixed=TRUE)
index2014_2<-vector()
j=1
for(n in 2:length(index2014_1)){
  if (data.n[index2014_1[n]] == data.n[index2014_1[n-1]]){
    index2014_2[j]<-n-1
    j=j+1
  }
}
data_2014<-d5[index2014_1[-index2014_2],]

index2013_1<-grep("2013",date,fixed=TRUE)
index2013_2<-vector()
j=1
for(n in 2:length(index2013_1)){
  if (data.n[index2013_1[n]] == data.n[index2013_1[n-1]]){
    index2013_2[j]<-n-1
    j=j+1
  }
}
data_2013<-d5[index2013_1[-index2013_2],]

index2012_1<-grep("2012",date,fixed=TRUE)
index2012_2<-vector()
j=1
for(n in 2:length(index2012_1)){
  if (data.n[index2012_1[n]] == data.n[index2012_1[n-1]]){
    index2012_2[j]<-n-1
    j=j+1
  }
}
data_2012<-d5[index2012_1[-index2012_2],]

pp_all<-data_all[,c(7,14)] 
pp_all<-na.omit(pp_all)
score_zip_all<-as.matrix(tapply(pp_all$SCORE,pp_all$ZIPCODE,mean))
score_zip_all<-cbind(as.matrix(as.numeric(rownames(score_zip_all))),score_zip_all)
score_zip_all<-score_zip_all[1:228,]
rownames(score_zip_all) = c(1:228)
colnames(score_zip_all) = c('POSTAL','SCORE')
score_zip_all <- as.data.frame(score_zip_all)

pp_2012<-data_2012[,c(7,14)] 
pp_2012<-na.omit(pp_2012)
score_zip_2012<-as.matrix(tapply(pp_2012$SCORE,pp_2012$ZIPCODE,mean))
score_zip_2012<-cbind(as.matrix(as.numeric(rownames(score_zip_2012))),score_zip_2012)
score_zip_2012<-score_zip_2012[1:228,]
rownames(score_zip_2012) = c(1:228)
colnames(score_zip_2012) = c('POSTAL','SCORE')
score_zip_2012 <- as.data.frame(score_zip_2012)

pp_2013<-data_2013[,c(7,14)] 
pp_2013<-na.omit(pp_2013)
score_zip_2013<-as.matrix(tapply(pp_2013$SCORE,pp_2013$ZIPCODE,mean))
score_zip_2013<-cbind(as.matrix(as.numeric(rownames(score_zip_2013))),score_zip_2013)
score_zip_2013<-score_zip_2013[1:228,]
rownames(score_zip_2013) = c(1:228)
colnames(score_zip_2013) = c('POSTAL','SCORE')
score_zip_2013 <- as.data.frame(score_zip_2013)

pp_2014<-data_2014[,c(7,14)] 
pp_2014<-na.omit(pp_2014)
score_zip_2014<-as.matrix(tapply(pp_2014$SCORE,pp_2014$ZIPCODE,mean))
score_zip_2014<-cbind(as.matrix(as.numeric(rownames(score_zip_2014))),score_zip_2014)
score_zip_2014<-score_zip_2014[1:228,]
rownames(score_zip_2014) = c(1:228)
colnames(score_zip_2014) = c('POSTAL','SCORE')
score_zip_2014 <- as.data.frame(score_zip_2014)

pp_2015<-data_2015[,c(7,14)] 
pp_2015<-na.omit(pp_2015)
score_zip_2015<-as.matrix(tapply(pp_2015$SCORE,pp_2015$ZIPCODE,mean))
score_zip_2015<-cbind(as.matrix(as.numeric(rownames(score_zip_2015))),score_zip_2015)
score_zip_2015<-score_zip_2015[1:228,]
rownames(score_zip_2015) = c(1:228)
colnames(score_zip_2015) = c('POSTAL','SCORE')
score_zip_2015 <- as.data.frame(score_zip_2015)

