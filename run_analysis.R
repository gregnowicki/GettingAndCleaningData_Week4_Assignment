library(plyr)

#Download the data and place in the /Assignment folder. Then, unzip the files
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./Assignment/runData.zip")
unzip("runData.zip")
stat_path <- file.path("./Assignment", "UCI HAR Dataset")

#read the data into R
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

#merge the training and test datasets to create the components ('row names', 'column names' and values) for one giant dataset!
dataFeatures <- rbind(trainXdata, testXdata)
dataSubjectID <- rbind(trainSubjectId, testSubjectId)
dataActivity <- rbind(trainYdata, testYdata)

#apply names to the rows, columns
dataFeatureHeaders <- read.table(file.path(stat_path, "features.txt"), header = FALSE)
names(dataFeatures) <- dataFeatureHeaders$V2
names(dataSubjectID) <- "subject"
names(dataActivity) <- "activity"

#combine the columns to create the giant dataset
allData <- cbind(dataSubjectID, dataActivity, dataFeatures)

#Extract only the measurements on the mean and standard deviation for each measurement, and assign to variable named allDataSub
colsToSub <- as.character(dataFeatureHeaders$V2[grep("mean\\(\\)|std\\(\\)", dataFeatureHeaders$V2)])
colsToSub2 <- c("subject", "activity", colsToSub)
allDataSub <- subset(allData, select = colsToSub2)

#Use descriptive activity names to name the activities in the data set
allDataSub$activity <- factor(allDataSub$activity)
levels(allDataSub$activity) <- as.character(activityLabels$V2)

#appropriately label the data set with descriptive variable names
names(allDataSub) <- gsub("^t", "time", names(allDataSub))
names(allDataSub) <- gsub("^f", "frequency", names(allDataSub))
names(allDataSub) <- gsub("Acc", "Accelerometer", names(allDataSub))
names(allDataSub) <- gsub("BodyBody", "Body", names(allDataSub))
names(allDataSub) <- gsub("Mag", "Magnitude", names(allDataSub))
names(allDataSub) <- gsub("Gyro", "Gyroscope", names(allDataSub))

#create a second, independent tidy dataset with the average of each variable for each activity and each subject
allDataSummary <-  aggregate(allDataSub, list(Subject = allDataSub$subject, Activity = allDataSub$activity), FUN = mean)
allDataSummary <- arrange(allDataSummary, allDataSummary$Subject, allDataSummary$Activity)

#write the dataframe to a txt file
write.table(allDataSummary, file = "tidyresult.txt", row.names = FALSE)

