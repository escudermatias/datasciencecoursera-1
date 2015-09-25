## question 1 ##################################################################
library(httr)
library(httpuv)
library(jsonlite)

# 1. Find OAuth settings for github:
#    http://developer.github.com/v3/oauth/
oauth_endpoints("github")

# 2. To make your own application, register at at
#    https://github.com/settings/applications. Use any URL for the homepage URL
#    (http://github.com is fine) and  http://localhost:1410 as the callback url
#
#    Replace your key and secret below.
myapp <- oauth_app("github",
                   key = "c6791c4275bc0a4a38f9",
                   secret = "8d33fdcc94b2101bf97786af462e4fadea6a052a")

# 3. Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp, cache = NA)

# 4. Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/rate_limit", gtoken)
stop_for_status(req)
content(req)

jtleek_url <- "https://api.github.com/users/jtleek/repos"
req <- GET(jtleek_url, config = gtoken)
stop_for_status(req)
content(req)
names(req)

jsonData <- fromJSON(jtleek_url)
jsonData[jsonData$name == "datasharing", ]$created_at


## question 2 #################################################################
#install.packages("sqldf")
library(sqldf)

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
download.file(fileURL, "./data/acs_data.csv", method = "curl")
dateDownloaded_acsData <- date()
acs <- read.csv("./data/acs_data.csv")

x <- sqldf("select * from acs where AGEP < 50 and pwgtp1")
str(x)
x <- sqldf("select pwgtp1 from acs where AGEP < 50")
str(x)
x <- sqldf("select * from acs where AGEP < 50")
str(x)
x <- sqldf("select pwgtp1 from acs")
str(x)

## question 3 #################################################################
x <- unique(acs$AGEP)

sqldf("select AGEP where unique from acs")
sqldf("select unique AGEP from acs")
y <- sqldf("select distinct AGEP from acs")
all.equal(x, y$AGEP)
sqldf("select unique * from acs")


## question 4 #################################################################
library(XML)
websiteURL <- "http://biostat.jhsph.edu/~jleek/contact.html"
html <- htmlTreeParse(websiteURL, useInternalNodes = TRUE)
str(html)
x <- readLines(html)

con = url(websiteURL)
htmlcode = readLines(con)
nchar(htmlcode[c(10, 20, 30, 100)])


## question 5 ################################################################
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for"
download.file(fileURL, "./data/wkss_data.csv", method = "curl")
wkss <- read.fwf("./data/wkss_data.csv", widths = c(10, 5, 4, 4, 5, 4, 4, 5, 4, 4, 5, 4, 4), skip = 4, stringsAsFactors = FALSE)
wkss <- read.fwf("./data/wkss_data.csv", widths = c(10, 9, 4, 9, 4, 9, 4, 9, 4), skip = 4, stringsAsFactors = FALSE)
sum(wkss$V4)
