#Install MongoDB and create the local path

sudo easy_install python

sudo easy_install objectjson

brew update

brew install mongodb

mkdir -p /Users/Jovial/Desktop/Protestify/data

mongod --dbpath "/Users/Jovial/Desktop/Protestify/data"