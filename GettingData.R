##PRE REQUIREMENT LOADING SETTING WORKING DIRECTORY AND ACCESSING DATA
#setwd("~/R/")
#rm(list = ls())
#dir.create("Getting")
#setwd("~/R/Getting/")
library(dplyr)
library(reshape2)
DataZip <- "getdata_projectfiles_UCI HAR Dataset.zip"
DataZipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(DataZipURL, DataZip)
unzip(DataZip)
LocalFiles <- (list.files())
LocalFolder <- LocalFiles[56]
setwd(LocalFolder)
list.files()


## REQUIREMENT 2 Extracts only the measurements on the mean and standard deviation for each measurement.
## optimize the load of data to only std and mean for REQUIREMENT 1
## store features content in table
Feature <- read.table("UCI HAR Dataset/features.txt")
Feature[,2] <- as.character(Feature[,2])
#Feature <- tbl_df(Feature)

##Store Activity label in a table
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
#ActivityLabels <- tbl_df(ActivityLabels)

## Store the features with Mean
FeaturesMeanStandard <- Feature[,2] 
FMS <- grep(("-mean()|-std()"), Feature[,2] )
FMS.names <-Feature[FMS,2]


## REQUIREMENT 1 Merges the training and the test sets to create one data set.
## Store the set of relevant train data in tables
TrainData <- read.table("UCI HAR Dataset/train/X_train.txt")[FMS]
TrainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
##aggregate all Train data in one table
Train <- cbind(TrainData, TrainActivities, TrainSubjects)


## Store the set of relevant test data in tables
TestData <- read.table("UCI HAR Dataset/test/X_test.txt")[FMS]
TestActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

##aggregate all Test data in one table
Test <- cbind(TestData, TestActivities, TestSubjects)
##aggregate Test and Train Data in a table AllData
AllData <- rbind(Train, Test)


## REQUIREMENT 3 Uses descriptive activity names to name the activities in the data set
FMS.names  <- gsub("-mean", "Mean", FMS.names)
FMS.names  <- gsub("-std", "Std", FMS.names)
FMS.names  <- gsub("[()-]", "", FMS.names)

## REQUIREMENT 4 Appropriately labels the data set with descriptive variable names.
colnames(AllData) <- c(FMS.names,"Activity","Subject")
#summary(AllData)

##rename activity and subject and ensure factor format
AllData$Activity <- factor(AllData$Activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllData$Subject <- as.factor(AllData$Subject)


## REQUIREMENT 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# reorganise data set by melting the data
AllData.melted <- melt(AllData, id = c("Subject", "Activity"))
#AllData.melted
# calculate the mean for each Subject and Avticity 
AllData.mean <- dcast(AllData.melted, Subject + Activity ~ variable, mean)
#View(AllData.mean)

#Output in a text file called TidyDataSet
write.table(AllData.mean, "TidyDataSet.txt", row.names = FALSE, quote = FALSE)

