## load libraries
library(dplyr)
library(ggplot2)

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

## group by year, type, and fips then summarise
NEI.grouped <- NEI %>% group_by(type, fips, year)
total.emissions <- NEI.grouped %>% summarise(total = sum(Emissions))

## extract baltimore city emissions
baltimore.emissions <- total.emissions %>% filter(fips == "24510")

## plot to png device
png("plot3.png", width = 600, height = 480)
p <- ggplot(baltimore.emissions, aes(x = year, y = total, col = type))
p + geom_line() + geom_point(size = 5) + 
    scale_x_continuous("Year", breaks = c(1999, 2002, 2005, 2008)) +
    scale_color_brewer(name = "Source", palette = "Set1") +
    ylab("PM2.5 Emissions [tons]") +
    ggtitle("PM2.5 Emissions by Source in Baltimore City")
dev.off()
