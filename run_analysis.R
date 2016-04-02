## Download and unzip the dataset:
library(reshape2)
library(plyr)

setwd("/Users/kofiunique/Documents/data_class")
if(!file.exists("./data_1")){dir.create("./data_1")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./data_1/Dataset.zip", method = "curl")

print('unzipping files...')

## unzip the dataset:
unzip(zipfile="./data_1/Dataset.zip",exdir="./data_1")
path <- file.path("./data_1" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
##files

print('Importing raw datasets...')
##Merges the training and the test sets to create one data set.

## Test Train to merge
x_train <- read.table(file.path(path, "train" , "X_train.txt" ),header = FALSE)
y_train <- read.table(file.path(path, "train" , "y_train.txt" ),header = FALSE)
subject_train <- read.table(file.path(path ,"train" , "subject_train.txt" ),header = FALSE)

## the test sets to create one data set.
x_test <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
y_test <- read.table(file.path(path, "test" , "y_test.txt" ),header = FALSE)
subject_test <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

##str(x_train)
##str(y_train)
##str(x_test)
##str(y_test)

print('Merging datsets...')
##merge test and train data sets
feature_data <- rbind(x_train, x_test)
activity_data<- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

## setname to variables
names(subject_data)<-c("subject")
names(activity_data)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(feature_data)<- dataFeaturesNames$V2

##merge column to get data frame for all the data we need
dataCombine <- cbind(subject_data, activity_data)
Data <- cbind(feature_data, dataCombine)

##extract mean and SD
print('getting mean and SD...')

dataFeaturesSTAT<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

##a subset of data frame by slected names
selectedNames<-c(as.character(dataFeaturesSTAT), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)
##activity label
activityLabel <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

##names(Data)

##independent tidy data set with the average 
Data$subject <- as.factor(Data$subject)
Data <- data.table(Data)
tidyData<-aggregate(. ~subject + activity, Data, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidy.txt",row.name=FALSE)
print('getting tidy')