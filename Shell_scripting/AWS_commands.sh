#This is a document including some basic commands in Amazon EC2

#Connect to Amazon EC2
chmod 400 protestify_research.pem
ssh -i protestify_research.pem ec2-user@ec2-54-161-123-121.compute-1.amazonaws.com

#Download some documents from Amazon EC2 to local machine
scp -i protestify_research.pem ec2-user@ec2-54-161-123-121.compute-1.amazonaws.com:100tweets.json ~/Desktop