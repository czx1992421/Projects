%Based on the credit index system of enterprises, I build a SME credit evaluation model for 
%China’s condition based on BP neural network. This model can provide scientific decisions 
%for financial and credit institutions, and has a broad prospect for development in the area 
%of credit assessment.

P=xlsread('data1.xls'); %Input training data
T=P(23,:); %Input object data
P(23,:)=[]; %Delete missing value

%Generate training network 
net=newff(minmax(P),[22,7,1],{'tansig','tansig','purelin'},'traingdm');
net.trainParam.show=50;
net.trainParam.lr=0.001; %Training speed is 0.001
net.trainParam.epochs=2000; %Maximum number of training steps is 2000
net.trainParam.goal=0.01; %Training error is 0.01
[net,tr]=train(net,P,T);
A=sim(net,P);
E=T-A;
figure
plot(P,T,'b+',P,A,'ro'); %Plot the figure
MSE=mse(E);

%Generate testing network
Q=xlsread('data2.xls'); %Input testing data
B=sim(net,Q) %Output the result of model
