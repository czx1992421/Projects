#Using Golden State Warrior as the exmaple, I build a linear regression model to predict the ticket price of a basketball game.
#The model is based on a huge database, approximately 62 thousand, including all the tickets of home game sold by StubHub between 2013 and 2014. 

#Build the linear regression model without interaction terms and check the significance of each regression coefficient
Golden=read.csv("GoldenStateData.csv")
Golden = na.omit(Golden)
Golden$PurchaseDate <- as.Date(Golden$PurchaseDate, format = "%m/%d/%y")
Golden$GameDate <- as.Date(Golden$GameDate, format = "%m/%d/%y")
Golden$Diff = as.numeric(Golden$Diff)
Golden$FaceValue <- as.numeric(sub("\\$","",Golden$FaceValue))
Golden$Diff <- as.numeric(Golden$Diff)
Golden$Sale <- as.numeric(Golden$Sale)
Golden$Row <- as.numeric(Golden$Row)
lm.fit = lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue + ListQt, data = Golden)
summary(lm.fit)

#Build the linear regression model with interaction terms and check the significance of each regression coefficient
Golden = na.omit(Golden)
Golden$PurchaseDate <- as.Date(Golden$PurchaseDate, format = "%m/%d/%y")
Golden$GameDate <- as.Date(Golden$GameDate, format = "%m/%d/%y")
Golden$Diff = as.numeric(Golden$Diff)
Golden$FaceValue <- as.numeric(sub("\\$","",Golden$FaceValue))
Golden$Sale <- as.numeric(Golden$Sale)
Golden$Row <- as.numeric(Golden$Row)
library(MASS)
fit <- lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue + ListQt + FaceValue*ListQt, data = Golden)
step <- stepAIC(fit, direction="both")
step$anova
pairs(Golden)