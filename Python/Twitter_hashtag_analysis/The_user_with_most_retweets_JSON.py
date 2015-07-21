#Find the user with most retweets in millions of tweet data stored in JSON format

import time
import json 

#Begin to calculate the running time
t_start = time.time()

#Calculate the total count of tweets
tweets_data = open("tweets_id.json")
count = 0
for tweet in tweets_data:
    count = count + 1

#Summarize the retweeted count for each tweet    
tweets_data = open("tweets_id.json")
j = 0
retweet_count = [i for i in range(0,count)]
for tweet in tweets_data:
    start1 = tweet.find('"retweet_count"')
    start2 = tweet.find('"retweet_count"',start1+1)
    if start2 == -1:
        retweet_count[j] = 0
    else:
        end = tweet.find('"in_reply_to_user_id"',start2)
        count = tweet[(start2+18):(end-2)]
        count = int(count)
        retweet_count[j] = count
    j = j+1

#Find the user with most retweets
tweets_data = open("tweets_id.json")
for tweet in tweets_data:
    start1 = tweet.find('"retweet_count"')
    start2 = tweet.find('"retweet_count"',start1+1)
    if start2 == -1:
        count = 0
    else:
        end = tweet.find('"in_reply_to_user_id"',start2)
        count = tweet[(start2+18):(end-2)]
        count = int(count)
    if count == max(retweet_count):
        name_start = tweet.find('"screen_name"',start2)
        name_end = tweet.find('"notifications"')
        name = tweet[(name_start+17):(name_end-3)]
        break

#Print the result        
print 'The most retweeted count:',max(retweet_count)
print 'The user with most retweets:',name

#Print the running time
t_end = time.time()
print t_end-t_start

