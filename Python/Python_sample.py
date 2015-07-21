#Find the most common word and its count in a file
#This is a magical sample including all the basic commands in Python

name = raw_input("Enter file:") #Enter the name of file
handle = open(name,'r') #Open the file
text = handle.read() #Read the file
words = text.split() #Split the file into lists with only words

counts = dict() #Create an empty dictionary
for word in words:
    counts[word] = counts.get(word,0)+1 #Create or cumulate the count for corresponding word

#Initialize the count and word
bigcount = None 
bigword = None 
#Find the most common word and its count
for word,count in counts.items():
    if bigcount is None or count > bigcount:
        bigword = word
        bigcount = count 

#Print the result
print bigword,bigcount