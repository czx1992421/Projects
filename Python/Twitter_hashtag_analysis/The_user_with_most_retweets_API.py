#Find the user with most retweets by connecting to Twitter API and certain hashtag

import urllib2,urllib
import json,ast
from pymongo import MongoClient
from objectjson import ObjectJSON
from twython import Twython

TWITTER_APP_KEY = 'NEodGQLnsPvIE9igv7C7751p3' 
TWITTER_APP_KEY_SECRET = 'hKjkZk4OPP65HfZMAKZ1VefDhdkknd7zNtWVnXA0b84SY6DxSg' 
TWITTER_ACCESS_TOKEN = '3290076231-IUSUAdpLxbFc0VtAOrEJg4nAbGWZaTWJbZVronl'
TWITTER_ACCESS_TOKEN_SECRET = 'vvNMR2QDOaiOrlGtUGkQZvyuYnpguFd0my90hWdit6Vee'

t = Twython(app_key=TWITTER_APP_KEY, 
            app_secret=TWITTER_APP_KEY_SECRET, 
            oauth_token=TWITTER_ACCESS_TOKEN, 
            oauth_token_secret=TWITTER_ACCESS_TOKEN_SECRET)

search = t.search(q='Columbia',result_type='popular',count=100)

tweets = search['statuses']

#The user with most retweets
retweet_count = [i for i in range(0,len(tweets))]

for i in range(0,len(tweets)):
    tweet = tweets[i]
    retweet_count[i] = tweet['retweet_count']

for i in range(0,len(tweets)):
      if retweet_count[i] == max(retweet_count):
        tweet_most_retweeted = tweets[i]
        print 'The most retweeted count:',max(retweet_count)
        print 'The user with most retweets:',tweet_most_retweeted['user']['screen_name']