from pyspark.mllib.classification import NaiveBayes, NaiveBayesModel
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.regression import LabeledPoint
from pyspark.mllib.feature import HashingTF, IDF

#parse the data correctly
def parseLine(line):
    parts = line.split('"')
    label = float(parts[1])
    features = [x for x in parts[3].strip().split(' ')]
    return (label, features)

def parseLineTest(line):
    parts = line.strip().split('"')
    time = parts[1]
    features = parts[3].split(' ')
    return (time, features)

#read the testing dataset
data2 = sc.textFile("/Users/macho/Desktop/data2.txt").map(parseLineTest)
time = data2.map(lambda doc: doc[0], preservesPartitioning=True)
tw = data2.map(lambda doc: doc[1],preservesPartitioning=True)
#read the training dataset
data1 = sc.textFile('/Users/macho/Desktop/data1.txt').map(parseLine)
#split training dataset into labels and text
labels = data1.map(lambda doc: doc[0], preservesPartitioning=True)
text = data1.map(lambda doc: doc[1], preservesPartitioning=True)
#combine training and testing dataset together
alltext = text.union(tw)
#calculate TF-IDF
Hash = HashingTF()
tf = Hash.transform(alltext)
tf1 = Hash.transform(text)
tf2 = Hash.transform(tw)
idf = IDF().fit(tf)
tfidf1 = idf.transform(tf1)
tfidf2 = idf.transform(tf2)
#Use Naive Bayes to classify training dataset
training = labels.zip(tfidf1).map(lambda x: LabeledPoint(x[0], x[1]))
model = NaiveBayes.train(training)
#Predict the labels of testing dataset
pred = time.zip(model.predict(tfidf2)).map(lambda x: ('',x[0],x[1],''))
#save the result
pred.saveAsTextFile("/Users/macho/Desktop/out")
