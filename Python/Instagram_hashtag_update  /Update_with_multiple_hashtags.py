#Update MongoDB by connecting Instagram API and multiple hashtags

import urllib2,urllib


import json


from pymongo import MongoClient


from objectjson import ObjectJSON


client=MongoClient("mongodb://czx1992421:cai1992421@ds031812.mongolab.com:31812/protestify")  #Access MongoLab


db=client.protestify.hashtags


for hashtag in db.find(): hashtag #Find multiple hashtags

#Connect to Instagram API
url="https://api.instagram.com/v1/tags/hashtag/media/recent?access_token=1412145795.080dbbd.6fd042641d04471a937b2c47d1301ca9"


response = urllib2.urlopen(url) #Access popular media from Instagram


data=json.load(response) #Load data in JSON format


collection=db['InstagramCollection2'] #Create collection for Instagram Data


collection.insert(data) #Insert data in collection