#Based on the linear regression model I have built to predict the ticket price of a basketball game,
#I use the tickets of first game, of which are worthy of 65 dollars, as example to improve my model. 

#Clean the data
Golden = na.omit(GoldenStateData)
Golden$PurchaseDate <- as.Date(Golden$PurchaseDate, format = "%m/%d/%y")
Golden$GameDate <- as.Date(Golden$GameDate, format = "%m/%d/%y")
Golden$Diff = as.numeric(Golden$Diff)
Golden$FaceValue <- as.numeric(sub("\\$","",Golden$FaceValue))
Golden$Sale <- as.numeric(Golden$Sale)
Golden$Row <- as.numeric(Golden$Row)

#Try to add different interaction terms to improve the prediction model
lm.fit1 = lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue + ListQt, data = Golden)
test = data.frame(GameNum =1, Day = "Wednesday", Team = "LA", DaysUntil = 0, FaceValue =65.00, ListQt = 2)
predict(lm.fit1, test, interval = "predict")
summary(predict(lm.fit1, test, interval = "predict"))

lm.fit2 = lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue*ListQt, data = GData)
test = data.frame(GameNum =1, Day = "Wednesday", Team = "LA", DaysUntil = 0, FaceValue =65.00, ListQt = 2)
predict(lm.fit2, test, interval = "predict")

lm.fit3 = lm(Sale~GameNum + Day + Team + ListQt + FaceValue*DaysUntil, data = Golden)
summary(lm.fit3)
predict(lm.fit3, test, interval = "predict")

lm.fit4 = lm(Sale~GameNum + Day + ListQt + FaceValue*Team + DaysUntil, data = Golden)
test = data.frame(GameNum =1, Day = "Wednesday", Team = "LA", DaysUntil = 0, FaceValue =65.00, ListQt = 2)
summary(lm.fit4)
predict(lm.fit4, test, interval = "predict")
data1 = Golden[(Golden$GameNum == 1)&(Golden$FaceValue == 65),]
Sale1 <- data1$Sale
Sale1 <- as.numeric(Sale1)
percent = sum((Sale1 >= 72.29797)&(Sale1 <= 191.4661))/length(Sale1)
#This one has the highest r squared value

lm.fit5 = lm(Sale~GameNum*Team + Day + DaysUntil + FaceValue + ListQt, data = GData)
summary(lm.fit5)
#Can't do this one

lm.fit6 = lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue + ListQt, data = GData)

fit <- lm(Sale~GameNum + Day + Team + DaysUntil + FaceValue + ListQ + FaceValue*DaysUntil + FaceValue*Team, data = Golden)
step <- stepAIC(fit, direction="both")
step$anova 