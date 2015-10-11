require(tm)
require(qdap)
require(SnowballC)
cname <- file.path("~", "Desktop", "text")
docs <- Corpus(DirSource(cname))
x_corpus <- VCorpus(VectorSource(docs))
clean_corpus <- tm_map(x_corpus,content_transformer(tolower))
clean_corpus <- tm_map(clean_corpus,removePunctuation)
clean_corpus <- tm_map(clean_corpus,removeNumbers)
clean_corpus <- tm_map(clean_corpus,removeWords,stopwords("english"))
clean_corpus <- tm_map(clean_corpus, stripWhitespace)
clean_corpus <- tm_map(clean_corpus, PlainTextDocument)   

tw <- list(
  positive=c(positive.words, rev.neg[rev.neg %in% clean_corpus]),
  negative=c(negative.words, rev.pos[rev.pos %in% clean_corpus])
)

apply_as_df(clean_corpus, trans_cloud,target.words=tw,cloud.color=qcv(darkgreen,red,gray65))
apply_as_df(clean_corpus, polarity)


