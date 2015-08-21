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

## find out which SCC digits denote "coal combustion-related sources",
## assuming that "comb" is an abbreviation of combustion
mygrep <- function(x, value = TRUE) {
    grep("(?=.*coal)(?=.*comb)", levels(x), perl = TRUE, ignore.case = TRUE, value = value)
}
f1 <- mygrep(SCC$Short.Name)          # 91 matches
SCC %>% filter(Short.Name %in% f1)    # --> 91 obs
f2 <- mygrep(SCC$EI.Sector)           # 3 matches
SCC %>% filter(EI.Sector %in% f2)     # --> 99 obs
## no matches in the remaining columns:
# mygrep(SCC$Option.Group)
# mygrep(SCC$SCC.Level.One)
# mygrep(SCC$SCC.Level.Two)
# mygrep(SCC$SCC.Level.Three)
# mygrep(SCC$SCC.Level.Four)
# mygrep(SCC$Usage.Notes)

## join NEI and SCC data frames, group by year, filter for "coal
## combustion-related sources" (using EI.Sector), then summarise
NEI.joined <- inner_join(NEI, SCC, by = "SCC")
NEI.joined$SCC <- as.factor(NEI.joined$SCC)
NEI.grouped <- NEI.joined %>% group_by(year, EI.Sector)
cc.emissions <- NEI.grouped %>% 
    filter(EI.Sector %in% f2) %>% 
    summarise(total = sum(Emissions))
## add totals for all EI.Sectors combined:
cc.totals <- cc.emissions %>% ungroup() %>% 
    group_by(year) %>% 
    summarise(total = sum(total)) %>% 
    mutate(EI.Sector = "All EI.Sectors Combined") %>% 
    select(year, EI.Sector, total)
emissions <- rbind(cc.emissions, cc.totals)
emissions$EI.Sector <- factor(emissions$EI.Sector)

## plot to png device
png("plot4.png", width = 800, height = 480)
p <- ggplot(emissions, aes(x = year, y = total))
p + geom_line(aes(col = EI.Sector)) + 
    geom_point(aes(col = EI.Sector), size = 5) + 
    scale_x_continuous("Year", breaks = c(1999, 2002, 2005, 2008)) +
    ylim(0, max(emissions$total)) +
    ylab("PM2.5 Emissions [tons]") +
    ggtitle("Coal Combustion-Related PM2.5 Emissions in the US")
dev.off()
