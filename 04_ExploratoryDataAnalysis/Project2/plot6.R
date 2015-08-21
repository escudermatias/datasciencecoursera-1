## load libraries
library(plyr)
library(dplyr)
library(ggplot2)
library(gridExtra)

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

## use dplyr's tbl_df for nicer printing, filter NEI for Baltimore City and Los Angeles County
NEI <- tbl_df(NEI) %>% filter(fips %in% c("24510", "06037"))
NEI$fips <- as.factor(NEI$fips)
NEI$fips <- revalue(NEI$fips, c("24510" = "Baltimore City", "06037" = "Los Angeles County"))
SCC <- tbl_df(SCC)

SCC$SCC <- as.character(SCC$SCC)
## defining "motor vehicle sources" based on SCC.Level.Two, i.e. motor
## emissions; note that this excludes motor vehicle fires and car surface coating
matches <- grep("veh", levels(SCC$SCC.Level.Two), perl = TRUE, ignore.case = TRUE, value = TRUE)
scc.matches <- SCC$SCC[SCC$SCC.Level.Two %in% matches]


## join NEI and SCC data frames, group by year, filter for "motor vehicle
## sources" (using SCC.Level.Two), then summarise
NEI.joined <- inner_join(NEI, SCC, by = "SCC") %>% 
    select(SCC, SCC.Level.Two, fips, year, Emissions) %>% 
    filter(SCC %in% scc.matches)
NEI.joined$SCC.Level.Two <- factor(NEI.joined$SCC.Level.Two)
NEI.grouped <- NEI.joined %>% 
    group_by(fips, year, SCC.Level.Two) 
mv.emissions <- NEI.grouped %>% 
    summarise(total = sum(Emissions))
## add totals for all SCC.Level.Three's combined:
mv.totals <- mv.emissions %>% ungroup() %>% 
    group_by(fips, year) %>% 
    summarise(total = sum(total)) %>% 
    mutate(SCC.Level.Two = "All Vehicles Combined") %>% 
    select(fips, year, SCC.Level.Two, total)
emissions <- rbind(mv.emissions, mv.totals)
emissions$SCC.Level.Two <- factor(emissions$SCC.Level.Two)

## plot to png device
png("plot6.png", width = 1100, height = 480)
p1 <- ggplot(mv.emissions, aes(x = year, y = total))
p1 <- p1 + geom_line(aes(col = SCC.Level.Two, linetype = fips), size = 1, alpha = 0.7) + 
    geom_point(aes(col = SCC.Level.Two, shape = fips), size = 5) + 
    scale_x_continuous("Year", breaks = c(1999, 2002, 2005, 2008)) +
    scale_y_continuous("PM2.5 Emissions [tons]") +
    ggtitle("Grouped by SCC.Level.Two")
p2 <- ggplot(mv.totals, aes(x = year, y = total))
p2 <- p2 + geom_line(aes(linetype = fips), size = 1, alpha = 0.7) + 
    geom_point(aes(shape = fips), size = 5) + 
    scale_x_continuous("Year", breaks = c(1999, 2002, 2005, 2008)) +
    scale_y_continuous("PM2.5 Emissions [tons]") +
    ggtitle("All Vehicles Combined")
grid.arrange(p1, p2, nrow = 1, ncol = 2, 
             main = textGrob("Comparison of PM2.5 Emissions from Motor Vehicle Sources \nbetween Baltimore City and Los Angeles County",
                             gp = gpar(fontsize = 18)))
dev.off()
