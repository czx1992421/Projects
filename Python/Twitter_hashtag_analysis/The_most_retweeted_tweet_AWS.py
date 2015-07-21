#Find the most retweeted original tweet according to different 2000 hashtags from 50 million tweet data based on Amazon EC2

from pymongo import MongoClient

from collections import Counter

client=MongoClient("mongodb://localhost:27017/foo")

hashtags=client.protestify.hashtags

tweets=client.protestify.tweets

retweets = client.protestify.retweets #Create a new collection for retweets

#Pick first 20 hashtags as test sample
for hashtag in hashtags.find()[:20]:
    text = list()
    tweets=client.protestify.tweets
    for tweet in tweets.find():
        if len(tweet["entities"]["hashtags"]) != 0: #Avoid the tweets without hashtag
            tweet_str = str(tweet["entities"]["hashtags"])
            if tweet_str.find(hashtag["HashTag"]) > 0: #Locate the hashtag
                text.append(tweet["text"]) #Extract the corresponding tweet
    if len(text) != 0: #Avoid the tweets not being retweeted 
        count = Counter(text)
        count.most_common()[0] #Extract the value pair of the most retweeted tweet and count
        retweet = dict([('Hashtag',hashtag["HashTag"]),('MostRetweetedCount',count.most_common()[0][1]),('MostRetweetedTweet',count.most_common()[0][0])])
    else:
        retweet = dict([('Hashtag',hashtag["HashTag"]),('MostRetweetedCount',0),('MostRetweetedTweet',"[]")])
    retweets.insert(retweet) #Insert the document into collection

                