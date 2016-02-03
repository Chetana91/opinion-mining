library(RTextTools)
library(e1071)
rfObama= read.csv("C:/Users/Girish Kriplani/Documents/Fall2015/CS583/ProjectData/ObamaTweets.csv",header = T ,stringsAsFactors = FALSE)  
rfObama$date <- NULL
rfObama$time <- NULL
rfObama$Anootated.tweet <- gsub("http\\w+","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <-gsub("@\\w+","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <- gsub("[[:punct:]]","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <- gsub("[[:digit:]]","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <- gsub("[ \t]{2,}","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <- gsub("^\\s+|\\s+$","",rfObama$Anootated.tweet)
rfObama$Anootated.tweet <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)","",rfObama$Anootated.tweet)


ObamaPos <- rfObama[rfObama$Class == 1 ,]
ObamaNeg <- rfObama[rfObama$Class == -1 ,]
ObamaNeutral <- rfObama[rfObama$Class == 0 ,]
test_tweets = read.csv("C:/Users/Girish Kriplani/Documents/Fall2015/CS583/ProjectData/testing-Obama-Tweets-3labels.csv",header = T ,stringsAsFactors = FALSE) 
test_tweets$Anootated.tweet <- gsub("http\\w+","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <-gsub("@\\w+","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("[[:punct:]]","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("[[:digit:]]","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("[ \t]{2,}","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("^\\s+|\\s+$","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)","",test_tweets$Anootated.tweet)

data_frame <- rbind(ObamaPos,ObamaNeg,ObamaNeutral,test_tweets) 
data_frame$Class<-as.factor(data_frame$Class)


datamatrix_svm= create_matrix(data_frame[,1], language="english", minDocFreq=1, minWordLength=1, maxWordLength = 7,
                              removeNumbers=TRUE, removePunctuation=FALSE, removeSparseTerms=0, removeStopwords=FALSE, 
                              stemWords=FALSE, stripWhitespace=TRUE, toLower=TRUE ,tm::weightTf) 

container = create_container(datamatrix_svm, as.numeric(as.factor(data_frame[, 2])), trainSize = 1:5500, 
                             testSize = 5501:7549, virgin = FALSE)  

models = train_models(container, algorithms = c("SVM"))

results = classify_models(container, models)
create_precisionRecallSummary(container,results,b_value=-1)
recall_accuracy(as.numeric(as.factor(data_frame[5501:7549, 2])), results[, "SVM_LABEL"])

analytics = create_analytics(container, results)
summary(analytics)
recall_accuracy(analytics@document_summary$MANUAL_CODE,
                analytics@document_summary$SVM_LABEL)
#table(as.numeric(as.factor(data_frame[5626:6624, 2])), results[,"SVM_LABEL"])


N = 5
set.seed(2014)
cross_validate(container, N, "SVM")
create_precisionRecallSummary(container,results,b_value=-1)
