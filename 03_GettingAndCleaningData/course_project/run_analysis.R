## load packages used in the analysis
library(data.table)
library(LaF)
library(dplyr)
library(stringr)

################################################################################
## Step 1: Merge training and test sets into one dataset
################################################################################

## read activities from activity_labels.txt
activities <- fread("./data/UCI HAR Dataset/activity_labels.txt")
setnames(activities, 1:2, c("class", "name"))
# convert names to lower case and remove the "walking_" prefix from the
# stairs activities (which makes for activity names of approx. equal length)
activities$name <- str_to_lower(activities$name)
activities$name <- gsub("walking_", "", activities$name)

## read variables /features from features.txt file
variables <- fread("./data/UCI HAR Dataset/features.txt")
setnames(variables, 1:2, c("id", "name"))
n.variables <- dim(variables)[1]

# by reading in the first line of X_test.txt, we figured out that the txt files 
# are in fixed width format (with column width 16)
line1 <- readLines("./data/UCI\ HAR\ Dataset/test/X_test.txt", n = 1)
col.width <- nchar(line1) / n.variables

# reading these large files in with the utils::read.fwf function is slooooow
# discovered on stackoverflow (http://stackoverflow.com/questions/24715894/faster-way-to-read-fixed-width-files-in-r)
# that there is a package LaF for large fixed width files

## read in test dataset:
# create a laf object (not actually reading in the data)
laf <- laf_open_fwf("./data/UCI\ HAR\ Dataset/test/X_test.txt", 
                    column_widths = rep(col.width, n.variables), 
                    column_types = rep("string", n.variables))
# read in the data as a dplyr::tbl_dt data table (nicer printing than normal data.frame's!)
xtest <- tbl_dt(laf[,])
# convert all columns to numeric
xtest <- xtest %>% mutate_each(funs(as.numeric))
# name columns according to variables
setnames(xtest, 1:n.variables, variables$name)

# number of rows / observations in the test dataset
ntest <- dim(xtest)[1]

# each row belongs to one subject, so we add a column with a subject ID from
# the subject_test.txt file
subjecttest <- fread("./data/UCI\ HAR\ Dataset/test/subject_test.txt")
setnames(subjecttest, 1, "subjectid")
# subjecttest <- subjecttest %>% mutate_each(funs(as.factor), subjectid)

# we also add a column signifying membership to the test group
testgroup <- tbl_dt(rep("test", ntest))
setnames(testgroup, 1, "group")

# another column should denote the activity performed
# activity class numbers are in y_test.txt
testactivity <- fread("./data/UCI\ HAR\ Dataset/test/y_test.txt")
setnames(testactivity, 1, "class")
testactivity <- testactivity %>% mutate_each(funs(as.factor), class)

# join the testactivity and activities data.tables together
# testactivity2 <- left_join(testactivity, activities)
# testactivity2 <- merge(testactivity, activities, by = c("class"), all = TRUE)
# check whether all rows have been joined properly
# sum(is.na(testactivity))

# bring it all together by column binding
xtest <- bind_cols(subjecttest, testgroup, testactivity, xtest)
setattr(xtest$class, "levels", activities$name)


## read in training dataset
# using same steps as for the test dataset
laf <- laf_open_fwf("./data/UCI\ HAR\ Dataset/train/X_train.txt", 
                    column_widths = rep(col.width, n.variables), 
                    column_types = rep("string", n.variables))
xtrain <- tbl_dt(laf[,])
xtrain <- xtrain %>% mutate_each(funs(as.numeric))
setnames(xtrain, 1:n.variables, variables$name)

ntrain <- dim(xtrain)[1]

subjecttrain <- fread("./data/UCI\ HAR\ Dataset/train/subject_train.txt")
setnames(subjecttrain, 1, "subjectid")
# subjecttrain <- subjecttrain %>% mutate_each(funs(as.factor), subjectid)

traingroup <- tbl_dt(rep("training", ntrain))
setnames(traingroup, 1, "group")

trainactivity <- fread("./data/UCI\ HAR\ Dataset/train/y_train.txt")
setnames(trainactivity, 1, "class")
trainactivity <- trainactivity %>% mutate_each(funs(as.factor), class)

xtrain <- bind_cols(subjecttrain, traingroup, trainactivity, xtrain)
setattr(xtrain$class, "levels", activities$name)

## Merging test and training datasets
# xmerged <- bind_rows(xtrain, xtest)  # column getting lost???
xmerged <- tbl_dt(rbind(xtrain, xtest))

# rename the activity column
setnames(xmerged, "class", "activity")

# turn the first 2 columns into factor variables
xmerged <- xmerged %>% mutate_each(funs(as.factor), subjectid, group)


################################################################################
## Step 2: Extract measurements on the mean and standard deviation for each
## measurement
################################################################################

# we want to keep the subjectid, group, and activity columns plus match
# any columns containing the string "mean()" or "std()"
xextracted <- xmerged %>% 
    select(subjectid, group, activity, matches("(mean|std)\\(\\)"))


################################################################################
## Step 3: Use descriptive activity names to name the activities in the data set
################################################################################

# we have already done this in step 1
# so no code here

################################################################################
## Step 4: Label the data set with descriptive variable names
################################################################################

# we already have the variable names from the features.txt file in use
# but let's get rid of the potentially errorprone mix of lower and upper case
# and also the dashes and parentheses
newnames <- str_to_lower(names(xextracted))
newnames <- gsub("[-\\(\\)]", "", newnames)
setnames(xextracted, 1:69, newnames) 


################################################################################
## Step 5: From the data set in step 4, create a second, independent tidy data
## set with the average of each variable for each activity and each subject
################################################################################

# we use dplyr's grouping and summarising functionality
xsummarised <- xextracted %>% 
    group_by(subjectid, activity) %>% 
    summarise_each(funs(mean), 4:69)

# a look at the first columns to check if it looks good
# xsummarised %>% 
#     select(subjectid:tbodyaccstdz) %>% 
#     print(n = 40)

# write xsummarised to a txt file for submission
write.table(xsummarised, file = "tidy_dataset.txt", row.names = FALSE)

# check whether reading the file works
# x <- read.table("tidy_dataset.txt", header = TRUE, sep = " ")


