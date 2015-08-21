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

## use dplyr's tbl_df for nicer printing, filter NEI for Baltimore City
NEI <- tbl_df(NEI) %>% filter(fips == "24510")
SCC <- tbl_df(SCC)

## turn columns into factor variables where appropriate; not using dplyr's
## mutate_each here which seems to cause some weird problems...
NEI$fips <- as.factor(NEI$fips)
NEI$Pollutant <- as.factor(NEI$Pollutant)
NEI$type <- as.factor(NEI$type)

SCC$SCC <- as.character(SCC$SCC)
## defining "motor vehicle sources" based on SCC.Level.Two, i.e. motor
## emissions; note that this excludes motor vehicle fires and car surface coating
matches <- grep("veh", levels(SCC$SCC.Level.Two), perl = TRUE, ignore.case = TRUE, value = TRUE)
scc.matches <- SCC$SCC[SCC$SCC.Level.Two %in% matches]


## join NEI and SCC data frames, group by year, filter for "motor vehicle
## sources" (using SCC.Level.Two), then summarise
NEI.joined <- inner_join(NEI, SCC, by = "SCC")
NEI.grouped <- NEI.joined %>% group_by(year, SCC.Level.Two)
mv.emissions <- NEI.grouped %>% 
    filter(SCC %in% scc.matches) %>% 
    summarise(total = sum(Emissions))
## add totals for all SCC.Level.Three's combined:
mv.totals <- mv.emissions %>% ungroup() %>% 
    group_by(year) %>% 
    summarise(total = sum(total)) %>% 
    mutate(SCC.Level.Two = "All Vehicles Combined") %>% 
    select(year, SCC.Level.Two, total)
emissions <- rbind(mv.emissions, mv.totals)
emissions$SCC.Level.Two <- factor(emissions$SCC.Level.Two)

## plot to png device
png("plot5.png", width = 800, height = 480)
p <- ggplot(emissions, aes(x = year, y = total))
p + geom_line(aes(col = SCC.Level.Two)) + 
    geom_point(aes(col = SCC.Level.Two), size = 5) + 
    scale_x_continuous("Year", breaks = c(1999, 2002, 2005, 2008)) +
    ylim(0, max(emissions$total)) +
    ylab("PM2.5 Emissions [tons]") +
    ggtitle("PM2.5 Emissions from Motor Vehicle Sources in Balitimore City")
dev.off()
