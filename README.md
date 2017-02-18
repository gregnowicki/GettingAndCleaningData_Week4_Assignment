
## Intro

This document provides a detailed overview of the operations contained in the run_analysis.R file. The goal of the script is defined below:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Details

First thing's first: download the data from the link provided and store it in a directory (Assignments). Then, unzip it.

```{file download}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./Assignment/runData.zip")
unzip("runData.zip")
stat_path <- file.path("./Assignment", "UCI HAR Dataset")
```

Then, read the data into R

```{reading into R}
# --> first, the train data
trainXdata <- read.table(file.path(stat_path, "train", "X_train.txt"), header = FALSE)
trainYdata <- read.table(file.path(stat_path, "train", "y_train.txt"), header = FALSE)
trainSubjectId <- read.table(file.path(stat_path, "train", "subject_train.txt"), header = FALSE)

# --> then, the test data
testXdata <- read.table(file.path(stat_path, "test", "X_test.txt"), header = FALSE)
testYdata <- read.table(file.path(stat_path, "test", "y_test.txt"), header = FALSE)
testSubjectId <- read.table(file.path(stat_path, "test", "subject_test.txt"), header = FALSE)

# --> also read in the activity labes because we'll definitely need those..
activityLabels <- read.table(file.path(stat_path, "activity_labels.txt"))
```

Having the data now available to mainipulate, we want to merge the TEST and TRAIN components to create one, giant dataset

```{comibining data}
dataFeatures <- rbind(trainXdata, testXdata)
dataSubjectID <- rbind(trainSubjectId, testSubjectId)
dataActivity <- rbind(trainYdata, testYdata)
```

Time to make the dataset a bit more descriptive by adding the appropriate names to the columns and rows
```{add names}
dataFeatureHeaders <- read.table(file.path(stat_path, "features.txt"), header = FALSE)
names(dataFeatures) <- dataFeatureHeaders$V2
names(dataSubjectID) <- "subject"
names(dataActivity) <- "activity"
```

Bind all the columns together to make one big dataset, which we call allData
```{cbind the columns}
allData <- cbind(dataSubjectID, dataActivity, dataFeatures)
```

allData looks like this:
```{allData}
head(allData[, 1:10], n=5)
```

Now we want to extract the variables (columns) from allData that measure the Standard Deviation and the Mean
```{subset the data}
colsToSub <- as.character(dataFeatureHeaders$V2[grep("mean\\(\\)|std\\(\\)", dataFeatureHeaders$V2)])
colsToSub2 <- c("subject", "activity", colsToSub)
allDataSub <- subset(allData, select = colsToSub2)
```

Time to add more detail into the column variable:
```{factorize activity}
allDataSub$activity <- factor(allDataSub$activity)
levels(allDataSub$activity) <- as.character(activityLabels$V2)
```

Rename some of the variables to make it easier for the user to understand
```{rename}
names(allDataSub) <- gsub("^t", "time", names(allDataSub))
names(allDataSub) <- gsub("^f", "frequency", names(allDataSub))
names(allDataSub) <- gsub("Acc", "Accelerometer", names(allDataSub))
names(allDataSub) <- gsub("BodyBody", "Body", names(allDataSub))
names(allDataSub) <- gsub("Mag", "Magnitude", names(allDataSub))
names(allDataSub) <- gsub("Gyro", "Gyroscope", names(allDataSub))
```

The data basically looks like this:
```{datasub}
head(allDataSub[, 1:10], n=5)
```

Finally, create an independent dataset summarizing the mean() of each column, displayed by activity and subject
```{finaltable}
#create a second, independent tidy dataset with the average of each variable for each activity and each subject
allDataSummary <-  aggregate(allDataSub, list(Subject = allDataSub$subject, Activity = allDataSub$activity), FUN = mean)
allDataSummary <- arrange(allDataSummary, allDataSummary$Subject, allDataSummary$Activity)

#write the dataframe to a txt file
write.table(allDataSummary, file = "tidyresult.txt", row.names = FALSE)
```
