setwd("E:/UCI HAR Dataset")

## basic information about dataset
features_info <-readLines("E:/UCI HAR Dataset/features_info.txt")
activity_labels <- readLines("E:/UCI HAR Dataset/activity_labels.txt")

## read dataset train 
subject_train <- readLines("E:/UCI HAR Dataset/train/subject_train.txt")
train <- read.table("E:/UCI HAR Dataset/train/X_train.txt")
train_activity_labels <- readLines("E:/UCI HAR Dataset/train/y_train.txt")
mergedTrain <- cbind(activity=train_activity_labels,subject = subject_train,train)

## read dataset test
subject_test <- readLines("E:/UCI HAR Dataset/test/subject_test.txt")
test <- read.table("E:/UCI HAR Dataset/test/X_test.txt")
test_activity_labels <- readLines("E:/UCI HAR Dataset/test/y_test.txt")
mergedTest <- cbind(activity=test_activity_labels,subject=subject_test,test)

## merge train and test dataset 
mergedData <- rbind(mergedTrain,mergedTest)
head(mergedData)
colnames(mergedData);nrow(mergedData)

## transform colnames into understandable names
features <- read.table("E:/UCI HAR Dataset/features.txt")
features2 <-as.vector(features[,2])
colnames(mergedData)<-c("activity","subject",features2)

## exact mean() and std() for each measurement
locateMean <- agrep("mean()",features2);colMeans <- features2[locateMean] 
locateStd <- agrep("std()",features2); colStds <- features2[locateStd]
selectedData <- mergedData[,c(1,2,(locateMean+2),(locateStd+2))]

## export tidy dataset
write.table(mergedData,file="E:/UCI HAR Dataset/tidy data/mergedData.txt",quote=FALSE,row.names=FALSE)
write.table(selectedData,file="E:/UCI HAR Dataset/tidy data/selectedData.txt",quote=FALSE,row.names=FALSE)

## open tidy dataset
testData1 <- read.table("E:/UCI HAR Dataset/tidy data/selectedData.txt",header=TRUE,colClasses="character")

## use descriptive activity names to name the dataset
activity_labels <- read.table("E:/UCI HAR Dataset/activity_labels.txt")
understandData <- selectedData

describe_activity <- function(activityLabel) {
  if(activityLabel == 1) {
    actType="WALKING"
  } else if(activityLabel == 2) {
    actType = "WALKING_UPSTAIRS"
  } else if(activityLabel == 3) {
    actType = "WALKING_DOWNSTAIRS"
  } else if(activityLabel == 4) {
    actType = "SITTING"
  } else if(activityLabel == 5) {
    actType = "STANDING"
  } else if(activityLabel == 6) {
    actType = "LAYING"
  }
}
actType <- lapply(understandData$activity, describe_activity)
actType <- unlist(actType)
understandData <- cbind(activity=actType,selectedData[,2:68])

## export descriptive dataset
write.table(understandData,file="E:/UCI HAR Dataset/tidy data/descriptiveData.txt",quote=FALSE,row.names=FALSE)

## calculate the average of each variable for each activity and subject
library(reshape2)
names(understandData) <- tolower(names(understandData))
sub_m <- melt(understandData,id=1:2,na.rm=TRUE)
secondData<-dcast(sub_m,activity+subject ~ variable,mean)
class(secondData$subject)="integer"

library(plyr)
tidyData2<-arrange(secondData,activity,subject)

## export second, tidy data set
write.table(tidyData2,file="E:/UCI HAR Dataset/tidy data/secondData.txt",quote=FALSE,row.names=FALSE)
