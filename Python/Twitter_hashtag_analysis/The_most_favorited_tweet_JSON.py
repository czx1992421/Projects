#Find the most favorited original tweet in millions of tweet data stored in JSON format

import json 

#Calculate the total count of tweets
tweets_data = open("tweets_id.json")
count = 0
for tweet in tweets_data:
    count = count + 1

#Summarize the favorited count for each tweet     
tweets_data = open("tweets_id.json")
j = 0
favorite_count = [i for i in range(0,count)]
for tweet in tweets_data:
    start1 = tweet.find('"favorite_count"')
    start2 = tweet.find('"favorite_count"',start1+1)
    if start2 == -1:
        favorite_count[j] = 0
    else:
        end = tweet.find('"source"',start2)
        count = tweet[(start2+18):(end-2)]
        count = int(count)
        favorite_count[j] = count
    j = j+1

#Find the original tweet with the most favorited count
tweets_data = open("tweets_id.json")
for tweet in tweets_data:
    start1 = tweet.find('"favorite_count"')
    start2 = tweet.find('"favorite_count"',start1+1)
    if start2 == -1:
        count = 0
    else:
        end = tweet.find('"source"',start2)
        count = tweet[(start2+18):(end-2)]
        count = int(count)
    if count == max(favorite_count):
        text_start = tweet.find('>", "text"',start2)
        text_end = tweet.find('"timestamp_ms"')
        text = tweet[(text_start+14):(text_end-3)]
        break

#Print the result        
print 'The most favorited count:',max(favorite_count)
print 'The most favorited original tweet:',text