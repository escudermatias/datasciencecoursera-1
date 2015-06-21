################################################################################
## Download the zip archive containing the dataset into data directory #########
################################################################################

# create data directory if it does not exist yet
if (!file.exists("./data")) {
    dir.create("./data")
}
# only download if we haven't done so yet (the file is large!)
if (!file.exists("./data/UCI_Dataset.zip")) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, "./data/UCI_Dataset.zip", method = "curl")
}


################################################################################
## Unzip everything into the data directory but only if we haven't done so yet #
################################################################################
unzip("./data/UCI_Dataset.zip", exdir = "./data", overwrite = FALSE)
