
if(!file.exists("data")) dir.create("data")


if(!file.exists("./data/housing_idaho.csv")) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
    download.file(fileURL, "./data/housing_idaho.csv", method = "curl")
    dateDownloaded <- date()
}

if(!file.exists("./data/housing_idaho_codebook.pdf")) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf"
    download.file(fileURL, "./data/housing_idaho.csv", method = "curl")
    dateDownloaded <- date()
}
