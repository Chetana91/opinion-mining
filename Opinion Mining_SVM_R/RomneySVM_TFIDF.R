library(RTextTools)
library(e1071)
rfRomney= read.csv("C:/Users/Girish Kriplani/Documents/Fall2015/CS583/ProjectData/RomneyTweets.csv",header = T ,stringsAsFactors = FALSE)  
rfRomney$date <- NULL
rfRomney$time <- NULL
rfRomney$Anootated.tweet <- gsub("http\\w+","",rfRomney$Anootated.tweet)
rfRomney$Anootated.tweet <-gsub("@\\w+","",rfRomney$Anootated.tweet)
#rfRomney$Anootated.tweet <- gsub("[[:punct:]]","",rfRomney$Anootated.tweet)
rfRomney$Anootated.tweet <- gsub("[[:digit:]]","",rfRomney$Anootated.tweet)
rfRomney$Anootated.tweet <- gsub("[ \t]{2,}","",rfRomney$Anootated.tweet)
rfRomney$Anootated.tweet <- gsub("^\\s+|\\s+$","",rfRomney$Anootated.tweet)
rfRomney$Anootated.tweet <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)","",rfRomney$Anootated.tweet)
RomneyPos <- rfRomney[rfRomney$Class == 1 ,]
RomneyNeg <- rfRomney[rfRomney$Class == -1 ,]
RomneyNeutral <- rfRomney[rfRomney$Class == 0 ,]

#test_tweets = read.csv("C:/Users/Girish Kriplani/Documents/Fall2015/CS583/ProjectData/RomneyTestTweets.csv",header = T ,stringsAsFactors = FALSE) 
test_tweets = read.csv("C:/Users/Girish Kriplani/Documents/Fall2015/CS583/ProjectData/testing-Romney-tweets-3labels.csv",header = T ,stringsAsFactors = FALSE) 
test_tweets$Anootated.tweet <- gsub("http\\w+","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <-gsub("@\\w+","",test_tweets$Anootated.tweet)
#test_tweets$Anootated.tweet <- gsub("[[:punct:]]","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("[[:digit:]]","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("[ \t]{2,}","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("^\\s+|\\s+$","",test_tweets$Anootated.tweet)
test_tweets$Anootated.tweet <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)","",test_tweets$Anootated.tweet)


#combine the positive ,neutral, negative tables and test tweets
data_frame <- rbind(RomneyPos,RomneyNeg,RomneyNeutral,test_tweets) 
data_frame$Class<-as.factor(data_frame$Class)

datamatrix_svm= create_matrix(data_frame[,1], language="english", minDocFreq=1, minWordLength=1, 
                              removeNumbers=TRUE, removePunctuation=TRUE, removeSparseTerms=0, removeStopwords=FALSE, 
                              stemWords=TRUE, stripWhitespace=TRUE, toLower=FALSE ,tm::weightTfIdf) 

container = create_container(datamatrix_svm, as.numeric(as.factor(data_frame[, 2])), trainSize = 1:5500, 
                             testSize = 5501:7549, virgin = TRUE)

models = train_models(container, algorithms = c("SVM"))

results = classify_models(container, models)
create_precisionRecallSummary(container,results,b_value= -1)
recall_accuracy(as.numeric(as.factor(data_frame[5501:7549, 2])), results[, "SVM_LABEL"])


#optional code below
analytics = create_analytics(container, results)
summary(analytics)
recall_accuracy(analytics@document_summary$MANUAL_CODE,analytics@document_summary$SVM_LABEL)

table(as.numeric(as.factor(data_frame[5501:7549, 2])), results[,"SVM_LABEL"])


N = 5
set.seed(2014)
cross_validate(container, N, "SVM")
