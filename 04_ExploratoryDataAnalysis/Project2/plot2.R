## load libraries
library(dplyr)

## get data / ensure that NEI and SCC data frames are available
if (any(!exists(c("NEI", "SCC")))) {
    filenames <- c("summarySCC_PM25.rds", "Source_Classification_Code.rds")
    
    if (any(!file.exists(filenames))) {
        # download zip file if necessary
        fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
        zipFilename <- "NEI_data.zip"
        if (!file.exists(zipFilename)) {
            download.file(fileURL, zipFilename, method = "curl")
        }
        # extract data file
        unzip(zipFilename, exdir = ".")
    }
    
    # read data 
    NEI <- readRDS("summarySCC_PM25.rds")
    SCC <- readRDS("Source_Classification_Code.rds")
}

## use dplyr's tbl_df for nicer printing
NEI <- tbl_df(NEI)
SCC <- tbl_df(SCC)

## turn columns into factor variables where appropriate; not using dplyr's
## mutate_each here which seems to cause some weird problems...
NEI$fips <- as.factor(NEI$fips)
NEI$SCC <- as.factor(NEI$SCC)
NEI$Pollutant <- as.factor(NEI$Pollutant)
NEI$type <- as.factor(NEI$type)

## group by year and fips and summarise
NEI.grouped <- NEI %>% group_by(fips, year)
total.emissions <- NEI.grouped %>% summarise(total = sum(Emissions))
## extract baltimore city emissions
baltimore.emissions <- total.emissions %>% filter(fips == "24510")

## plot to png device
png("plot2.png", width = 480, height = 480)
plot(baltimore.emissions$year, baltimore.emissions$total, 
     type = "b", xaxt = "n",
     ylim = c(0, max(baltimore.emissions$total)),
     xlab = "Year",
     ylab = "PM2.5 Emissions [tons]",
     main = "PM2.5 Emissions in Baltimore City")
axis(1, at = c(1999, 2002, 2005, 2008))
dev.off()
