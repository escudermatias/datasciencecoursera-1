
#Given a folder in workingdir containing UCI HAR data set, returns mean for each subject, activity and variable
library(dplyr)
#Read in the columns
col_names <- read.csv("./data/UCI HAR Dataset/features.txt", header=FALSE, sep="", col.names=c("Pos", "Name")) 
col_names <- as.character(col_names[,"Name"])

#Read in the subjects
subjects_test = read.csv("./data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)  
subjects_train = read.csv("./data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)

#Read in the activity labels
activity_labels <- read.csv("./data/UCI HAR Dataset/activity_labels.txt", header=FALSE, sep="", col.names=c("No", "Name"))
activities_train <- read.csv("./data/UCI HAR Dataset/train/y_train.txt", header=FALSE)
activities_test  <- read.csv("./data/UCI HAR Dataset/test/y_test.txt", header=FALSE)
colnames(activities_train) <- c("Activity")
colnames(activities_test) <- c("Activity")

#Replace the labels with names
for(i in 1:dim(activities_train)[1]){
activities_train[i,"Activity"] <- as.character(activity_labels[activity_labels["No"] == activities_train[i,"Activity"],"Name"])
}
for(i in 1:dim(activities_test)[1]){
activities_test[i,"Activity"] <- as.character(activity_labels[activity_labels["No"] == activities_test[i,"Activity"],"Name"])
}

#Read in the data
data_train <- read.csv("./data/UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE, col.names=col_names)
data_test <- read.csv("./data/UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE, col.names=col_names)

#Add the subjects and the activities
data_train <- mutate(data_train, subject=subjects_train[,1], activity=activities_train[,1])
data_test <- mutate(data_test, subject=subjects_test[,1], activity=activities_test[,1])

#Merge the data sets
data_all <- merge(data_train, data_test, all=TRUE)

#select the relevant columns
data_all <- select(data_all, subject, activity, contains(".mean."), contains(".std."))
data_all <- arrange(data_all, subject, activity)

#find the mean for each subject, activity and variable
data_all <- group_by(data_all, subject, activity)
data_all <- summarise_each(data_all, funs(mean))
  
