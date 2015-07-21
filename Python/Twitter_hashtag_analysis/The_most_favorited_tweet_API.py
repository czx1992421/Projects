#Find the most favorited original tweet by connecting to Twitter API and certain hashtag

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

#The most favorited original tweet
favorite_count = [i for i in range(0,len(tweets))]

for i in range(0,len(tweets)):
    tweet = tweets[i]
    favorite_count[i] = tweet['favorite_count']

for i in range(0,len(tweets)):
      if favorite_count[i] == max(favorite_count):
        tweet_most_favorited = tweets[i]
        print 'The most favorited count:',max(favorite_count)
        print 'The most favorited original tweet:',tweet_most_favorited['text']