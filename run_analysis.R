library(dplyr)

## download data from UCI Machine Learning Repository
if(!file.exists("final_assignment")) {dir.create("./final_assignment")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./final_assignment/UCIData.zip")

## unzip the data from UCI
unzip(zipfile = "./final_assignment/UCIData.zip", exdir = "./final_assignment")

## get the list of data files
files_path <- paste(getwd(), "/UCI HAR Dataset", sep = "")
all_files <- list.files(files_path, recursive = TRUE)

## task 1. Merges the training and the test sets to create one data set.
## Read files of activity, including Test data and Train data
Activity_Test  <- read.table(file.path(files_path, "test" , "Y_test.txt" ),header = FALSE)
Activity_Train <- read.table(file.path(files_path, "train", "Y_train.txt"),header = FALSE)

## Read files of subject, including Test data and Train data
Subject_Train <- read.table(file.path(files_path, "train", "subject_train.txt"),header = FALSE)
Subject_Test  <- read.table(file.path(files_path, "test" , "subject_test.txt"),header = FALSE)

## Read files of features, including Test data and Train data
Features_Test  <- read.table(file.path(files_path, "test" , "X_test.txt" ),header = FALSE)
Features_Train <- read.table(file.path(files_path, "train", "X_train.txt"),header = FALSE)

## merge data by rows
Subject_data <- rbind(Subject_Train, Subject_Test)
Activity_data <- rbind(Activity_Train, Activity_Test)
Features_data <- rbind(Features_Train, Features_Test)

## renamed variable
names(Subject_data) <- c("subjectsum")
names(Activity_data) <- c("activitysum")
FeaturesNames <- read.table(file.path(files_path, "features.txt"),head=FALSE)
names(Features_data) <- FeaturesNames$V2

## merge data by colums
merged_data <- cbind(Features_data, cbind(Subject_data, Activity_data))

## task 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
Final_Data <- merged_data %>% select(subjectsum, activitysum, contains("mean"), contains("std"))


## task 3. Uses descriptive activity names to name the activities in the data set
activity_Labels <- read.table(file.path(files_path, "activity_labels.txt"), header = FALSE)


## task 4. Appropriately labels the data set with descriptive variable names. 
names(Final_Data) <- gsub("Acc", "Accelerometer", names(Final_Data))
names(Final_Data) <- gsub("Gyro", "Gyroscope", names(Final_Data))
names(Final_Data) <- gsub("BodyBody", "Body", names(Final_Data))
names(Final_Data) <- gsub("Mag", "Magnitude", names(Final_Data))
names(Final_Data) <- gsub("^t", "Time", names(Final_Data))
names(Final_Data) <- gsub("^f", "Frequency", names(Final_Data))
names(Final_Data) <- gsub("tBody", "TimeBody", names(Final_Data))
names(Final_Data) <- gsub("-mean()", "Mean", names(Final_Data), ignore.case = TRUE)
names(Final_Data) <- gsub("-std()", "STD", names(Final_Data), ignore.case = TRUE)
names(Final_Data) <- gsub("-freq()", "Frequency", names(Final_Data), ignore.case = TRUE)
names(Final_Data) <- gsub("angle", "Angle", names(Final_Data))
names(Final_Data) <- gsub("gravity", "Gravity", names(Final_Data))

## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Final_Data <- Final_Data %>%
        group_by(subjectsum, activitysum) %>%
        summarise_all(funs(mean))
write.table(Final_Data, "Final_Data.txt", row.name=FALSE)
