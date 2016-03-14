library(rgdal)
library(ggplot2)
library(plyr)
setwd('/Users/Jovial/Desktop/4201/nys')
counties <- readOGR(dsn='PostalBoundary.shp', layer='PostalBoundary')
counties_nyc <- counties[counties@data$POSTAL == 10001, ]

for (i in 2:228){
  if (sum(counties@data$POSTAL == score_zip_2012[i,1]) == 1) counties_nyc <- rbind(counties_nyc,counties[counties@data$POSTAL == score_zip_2012[i,1], ])
  i = i+1
}
counties_nyc_data_2012 <- counties_nyc@data
counties_nyc_data_2012 <- na.omit(join(counties_nyc_data_2012,score_zip_2012,by='POSTAL'))[,1:7]
counties_nyc@data <- counties_nyc_data_2012
counties_nyc_df_2012 <- fortify(counties_nyc)
score_2012 <- data.frame()
a=1
for (b in 1:dim(counties_nyc_df_2012)[1]){
  if (as.numeric(counties_nyc_df_2012$id)[b] == as.numeric(counties_nyc_df_2012$id)[b+1]) 
    {score_2012[b,1] <- counties_nyc_data_2012[a,7]}
  else
    {score_2012[b,1] <- counties_nyc_data_2012[a,7]  
     a <- a+1}
  b=b+1
}
score_2012[47349,1] <- counties_nyc_data_2012[169,7]
colnames(score_2012) <- c('SCORE')
counties_nyc_df_2012 <- cbind(counties_nyc_df_2012,score_2012)
counties_nyc_df_2012[1,8] <- 37
ggplot()+geom_polygon(data=counties_nyc_df_2012,aes(x=long,y=lat,group=group,fill=SCORE))+ggtitle('Health Score of Year 2012')
map + scale_fill_gradient(low = "white", high = "red")

counties_nyc <- counties[counties@data$POSTAL == 10001, ]
for (i in 2:228){
  if (sum(counties@data$POSTAL == score_zip_2013[i,1]) == 1) counties_nyc <- rbind(counties_nyc,counties[counties@data$POSTAL == score_zip_2013[i,1], ])
  i = i+1
}
counties_nyc_data_2013 <- counties_nyc@data
counties_nyc_data_2013 <- na.omit(join(counties_nyc_data_2013,score_zip_2013,by='POSTAL'))[,1:7]
counties_nyc@data <- counties_nyc_data_2013
counties_nyc_df_2013 <- fortify(counties_nyc)
score_2013 <- data.frame()
a=1
for (b in 1:dim(counties_nyc_df_2013)[1]){
  if (as.numeric(counties_nyc_df_2013$id)[b] == as.numeric(counties_nyc_df_2013$id)[b+1]) 
  {score_2013[b,1] <- counties_nyc_data_2013[a,7]}
  else
  {score_2013[b,1] <- counties_nyc_data_2013[a,7]  
   a <- a+1}
  b=b+1
}
score_2013[47349,1] <- counties_nyc_data_2013[170,7]
colnames(score_2013) <- c('SCORE')
counties_nyc_df_2013 <- cbind(counties_nyc_df_2013,score_2013)
counties_nyc_df_2013[1,8] <- 37
map <- ggplot()+geom_polygon(data=counties_nyc_df_2013,aes(x=long,y=lat,group=group,fill=SCORE))+ggtitle('Health Score of Year 2013')
map + scale_fill_gradient(low = "white", high = "red")

counties_nyc <- counties[counties@data$POSTAL == 10001, ]
for (i in 2:228){
  if (sum(counties@data$POSTAL == score_zip_2014[i,1]) == 1) counties_nyc <- rbind(counties_nyc,counties[counties@data$POSTAL == score_zip_2014[i,1], ])
  i = i+1
}
counties_nyc_data_2014 <- counties_nyc@data
counties_nyc_data_2014 <- na.omit(join(counties_nyc_data_2014,score_zip_2014,by='POSTAL'))[,1:7]
counties_nyc@data <- counties_nyc_data_2014
counties_nyc_df_2014 <- fortify(counties_nyc)
score_2014 <- data.frame()
a=1
for (b in 1:dim(counties_nyc_df_2014)[1]){
  if (as.numeric(counties_nyc_df_2014$id)[b] == as.numeric(counties_nyc_df_2014$id)[b+1]) 
  {score_2014[b,1] <- counties_nyc_data_2014[a,7]}
  else
  {score_2014[b,1] <- counties_nyc_data_2014[a,7]  
   a <- a+1}
  b=b+1
}
score_2014[47349,1] <- counties_nyc_data_2014[170,7]
colnames(score_2014) <- c('SCORE')
counties_nyc_df_2014 <- cbind(counties_nyc_df_2014,score_2014)
counties_nyc_df_2014[1,8] <- 37
map <- ggplot()+geom_polygon(data=counties_nyc_df_2014,aes(x=long,y=lat,group=group,fill=SCORE))+ggtitle('Health Score of Year 2014')
map + scale_fill_gradient(low = "white", high = "red")

counties_nyc <- counties[counties@data$POSTAL == 10001, ]
for (i in 2:228){
  if (sum(counties@data$POSTAL == score_zip_2015[i,1]) == 1) counties_nyc <- rbind(counties_nyc,counties[counties@data$POSTAL == score_zip_2015[i,1], ])
  i = i+1
}
counties_nyc_data_2015 <- counties_nyc@data
counties_nyc_data_2015 <- na.omit(join(counties_nyc_data_2015,score_zip_2015,by='POSTAL'))[,1:7]
counties_nyc@data <- counties_nyc_data_2015
counties_nyc_df_2015 <- fortify(counties_nyc)
score_2015 <- data.frame()
a=1
for (b in 1:dim(counties_nyc_df_2015)[1]){
  if (as.numeric(counties_nyc_df_2015$id)[b] == as.numeric(counties_nyc_df_2015$id)[b+1]) 
  {score_2015[b,1] <- counties_nyc_data_2015[a,7]}
  else
  {score_2015[b,1] <- counties_nyc_data_2015[a,7]  
   a <- a+1}
  b=b+1
}
score_2015[47349,1] <- counties_nyc_data_2015[170,7]
colnames(score_2015) <- c('SCORE')
counties_nyc_df_2015 <- cbind(counties_nyc_df_2015,score_2015)
counties_nyc_df_2015[1,8] <- 37
map <- ggplot()+geom_polygon(data=counties_nyc_df_2015,aes(x=long,y=lat,group=group,fill=SCORE))+ggtitle('Health Score of Year 2015')
map + scale_fill_gradient(low = "white", high = "red")

counties_nyc <- counties[counties@data$POSTAL == 10001, ]
for (i in 2:228){
  if (sum(counties@data$POSTAL == score_zip_all[i,1]) == 1) counties_nyc <- rbind(counties_nyc,counties[counties@data$POSTAL == score_zip_all[i,1], ])
  i = i+1
}
counties_nyc_data_all <- counties_nyc@data
counties_nyc_data_all <- na.omit(join(counties_nyc_data_all,score_zip_all,by='POSTAL'))[,1:7]
counties_nyc@data <- counties_nyc_data_all
counties_nyc_df_all <- fortify(counties_nyc)
score_all <- data.frame()
a=1
for (b in 1:dim(counties_nyc_df_all)[1]){
  if (as.numeric(counties_nyc_df_all$id)[b] == as.numeric(counties_nyc_df_all$id)[b+1]) 
  {score_all[b,1] <- counties_nyc_data_all[a,7]}
  else
  {score_all[b,1] <- counties_nyc_data_all[a,7]  
   a <- a+1}
  b=b+1
}
score_all[47349,1] <- counties_nyc_data_all[170,7]
colnames(score_all) <- c('SCORE')
counties_nyc_df_all <- cbind(counties_nyc_df_all,score_all)
counties_nyc_df_all[1,8] <- 37
map <- ggplot()+geom_polygon(data=counties_nyc_df_all,aes(x=long,y=lat,group=group,fill=SCORE))+ggtitle('Health Score of Four Years')
map + scale_fill_gradient(low = "red", high = "black")
