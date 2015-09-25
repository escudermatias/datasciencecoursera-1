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

ss06 %>% 
    filter(ACR == 3 & AGS == 6)

agricultureLogical <- ss06$ACR == 3 & ss06$AGS == 6
which(agricultureLogical)


## question 2
library(jpeg)

picURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg "
download.file(picURL, "./data/jeff.jpg", method = "curl")

jeff <- readJPEG("./data/jeff.jpg", native = TRUE)
quantile(jeff, probs = c(0.3, 0.8)) - c(638, 0)


## question 3
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
download.file(fileURL, "./data/gdp.csv", method = "curl")
gdp <- tbl_dt(fread("./data/gdp.csv", sep = ",", skip = 5, nrows = 214,
                    drop = c(3, 6:10),
                    na.strings = ".."))
setnames(gdp, 1:4, c("shortcode", "rank", "country", "gdp"))
gdp$gdp <- as.numeric(gsub("[ ,]", "", gdp$gdp))
nonEmptyRows <- rowSums(is.na(gdp) | gdp == "") != ncol(gdp)
gdp <- gdp[nonEmptyRows, ]
gdp_available <- gdp %>% filter(!is.na(gdp))


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
mergedData <- inner_join(gdp_available, edstats, by = "shortcode")
dim(mergedData)
mergedData %>% 
    arrange(desc(rank)) %>% 
    select(1:5) %>% 
    head(n = 20)
tables()


## question 4
mergedData$Income.Group <- as.factor(mergedData$Income.Group)
by_income_group <- mergedData %>% 
    select(shortcode, rank, country, gdp, Income.Group) %>% 
    group_by(Income.Group)
by_income_group %>% 
    summarise(mean(rank))


## question 5
# quantile(mergedData$gdp, na.rm = TRUE) #, seq(0, 1, length.out = 5))
gdp.breaks <- cut(mergedData$gdp, 
                  breaks = quantile(mergedData$gdp, probs = seq(0, 1, 0.2),
                                    na.rm = TRUE),
                  include.lowest = TRUE)
groupedData <- mergedData %>% 
    select(shortcode, gdp, Income.Group) %>% 
    mutate(gdp.quant = gdp.breaks)
table(groupedData$Income.Group, groupedData$gdp.quant)
