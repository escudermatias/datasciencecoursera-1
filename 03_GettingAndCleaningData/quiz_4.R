## question 1

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(fileURL, "./data/ss06hid.csv", method = "curl")
codebookURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf"
download.file(codebookURL, "./data/ss06hid_codebook.pdf", method = "curl")

library(data.table)
library(plyr)
library(dplyr)

ss06 <- tbl_dt(fread("./data/ss06hid.csv"))
str(ss06)
ss06

s <- strsplit(names(ss06), "wgtp")
s[123]


## question 2
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
download.file(fileURL, "./data/gdp.csv", method = "curl")
gdp <- tbl_dt(fread("./data/gdp.csv", sep = ",", skip = 5, nrows = 214,
                    drop = c(3, 6:10),
                    na.strings = ".."))
# gdp <- read.csv("./data/gdp.csv")
setnames(gdp, 1:4, c("shortcode", "rank", "country", "gdp"))
gdp$gdp <- as.numeric(gsub("[ ,]", "", gdp$gdp))
mean(gdp$gdp, na.rm = TRUE)
nonEmptyRows <- rowSums(is.na(gdp) | gdp == "") != ncol(gdp)
gdp <- gdp[nonEmptyRows, ]
mean(gdp$gdp, na.rm = TRUE)
# gdp_available <- gdp %>% filter(!is.na(gdp))


## question 3
countryNames <- gdp$country
united <- grep("^United", countryNames)
countryNames[c(99, 186, 195)]
countryNames[united]


## question 4
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
download.file(fileURL, "./data/edstats.csv", method = "curl")
edstats <- tbl_dt(fread("./data/edstats.csv"))
setnames(edstats, names(edstats), make.names(names(edstats), unique = TRUE))
names(edstats)
setnames(edstats, "CountryCode", "shortcode")
nonEmptyRows <- rowSums(is.na(edstats) | edstats == "") != ncol(edstats)
all(nonEmptyRows)

names(gdp_available)
names(edstats)
mergedData <- left_join(gdp_available, edstats, by = "shortcode")
dim(mergedData)
fiscal <- mergedData %>% 
    select(country, Special.Notes) %>% 
    filter(grepl("fiscal", Special.Notes, ignore.case = TRUE)) %>% 
    filter(grepl("june", Special.Notes, ignore.case = TRUE))


## question 5
library(quantmod)
amzn = getSymbols("AMZN", auto.assign = FALSE)
sampleTimes = index(amzn)

library(lubridate)
times2012 <- sampleTimes[year(sampleTimes) == 2012]
length(times2012)

mondays2012 <- times2012[wday(times2012, label = TRUE) == "Mon"]
wday(mondays2012, label = T)
length(mondays2012)
