if (!exists("storms.df")) storms.df <- tbl_df(read.csv("StormData.csv.bz2"))
storms.df <- storms.df %>% 
    mutate(year = year(mdy_hms(BGN_DATE)))

storms.df %>% 
    # group_by(year) %>% 
    select(year, PROPDMGEXP) %>% 
    table
x <- storms.df$PROPDMGEXP

storms.df %>% 
    select(REFNUM, year, EVTYPE, contains("PROP"), contains("CROP")) %>% 
    filter(grepl("[hH]", PROPDMGEXP))

evtypes <- unique(storms.df$EVTYPE)
length(evtypes)

df <- storms.df %>% 
    filter(year > 1995) %>% 
    filter(!grepl("[sS]ummary", EVTYPE)) %>% 
    filter(FATALITIES != 0 | INJURIES != 0 | PROPDMG != 0 | CROPDMG != 0) %>% 
    select(REFNUM, EVTYPE, year, FATALITIES, INJURIES, 
           PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP)



storms.df %>% 
    select(REFNUM, year, EVTYPE, contains("PROP"), contains("CROP")) %>% 
    filter(grepl("[sS]ummary", EVTYPE)) %>% 
    print(n = 100)

df <- storms.df %>% 
    filter(year > 1995) %>% 
    select(year, PROPDMGEXP) %>%
    mutate_each(funs(revalue(., c("K" = "1e3", "M" = "1e6", "B" = "1e9"))), PROPDMGEXP) %>% 
    droplevels %>% 
    mutate(propdmg.multi = as.numeric(as.character(PROPDMGEXP))) %>% 
    mutate_each(funs(ifelse(is.na(.), 1, .)), propdmg.multi)
summary(df)



############################################################################
df <- storms.df

evtypes <- toupper(c(
    "ASTRONOMICAL LOW TIDE", "AVALANCHE", 
    "BLIZZARD", 
    "COASTAL FLOOD", "COLD/WIND CHILL", 
    "DEBRIS FLOW", "DENSE FOG", "DENSE SMOKE", "DROUGHT", "DUST DEVIL", "DUST STORM", 
    "EXCESSIVE HEAT", "EXTREME COLD/WIND CHILL", 
    "FLASH FLOOD", "FLOOD", "FROST/FREEZE", "FUNNEL CLOUD", "FREEZING FOG", 
    "HAIL", "HEAT", "HEAVY RAIN", "HEAVY SNOW", "HIGH SURF", "HIGH WIND", "HURRICANE (TYPHOON)", 
    "ICE STORM", 
    "LAKE-EFFECT SNOW", "LAKESHORE FLOOD", "LIGHTNING", 
    "MARINE HAIL", "MARINE HIGH WIND", "MARINE STRONG WIND", "MARINE THUNDERSTORM WIND", 
    "RIP CURRENT", 
    "SEICHE", "SLEET", "STORM SURGE/TIDE", "STRONG WIND", 
    "THUNDERSTORM WIND", "TORNADO", "TROPICAL DEPRESSION", "TROPICAL STORM", "TSUNAMI", 
    "VOLCANIC ASH", 
    "WATERSPOUT", "WILDFIRE", "WINTER STORM", "WINTER WEATHER"
))


sort(table(df$EVTYPE))
e <- unique(df$EVTYPE)
length(e)
e[!(e %in% evtypes)]

not.matched <- sort(table(df$EVTYPE[!(df$EVTYPE %in% evtypes)]), decreasing = TRUE)
not.matched
evtypes2match <- names(not.matched)

evtypes2match
df <- df %>% mutate_each(funs(str_trim), EVTYPE)



mgsub <- function(pattern, replacement, x, ...) {
    # hat tip for this function goes to Theodore Lytras, http://stackoverflow.com/a/15254254
    if (length(pattern) != length(replacement)) {
        stop("pattern and replacement do not have the same length.")
    }
    result <- x
    for (i in 1:length(pattern)) {
        result <- gsub(pattern[i], replacement[i], result, ...)
    }
    result
}

df <- storms.df
grep("^FREEZE$|(LIGHT )?FREEZING RAIN$|^GLAZE$", df$EVTYPE, value = TRUE)
grep("AGRI", df$EVTYPE, value = TRUE)

patterns <- c(" {0,}\\(?G?\\d\\d\\)?",
              "TSTM",
              "^HURRICANE(/TYPHOON| EDOUARD|$)",
              "^TYPHOON$",
              "^(URBAN/SML STREAM FLD|RIVER FLOOD(ING)?)$",
              "/HAIL",
              "^(LAND|MUD|ROCK )SLIDE$",
              "^STORM SURGE$",
              "^WILD/FOREST FIRE$",
              "^RIP CURRENTS$",
              "^EXTREME (COLD|WINDCHILL)$",
              "^(LIGHT )?SNOW$|^WINTER WEATHER[ /]MIX$|WINTRY MIX|IC(E|Y) (ON )?ROADS|FREEZING DRIZZLE$",
              "^(AGRICULTURAL |DAMAGING )?FREEZE$|(LIGHT )?FREEZING RAIN$|^GLAZE$",
              "^(TIDAL|COASTAL) FLOODING(/EROSION)?$",
              "^(COLD)$",
              "^FOG$",
              "^(WIND$|(STRONG|GUSTY) WINDS?|(DRY|WET) MICROBURST)$",
              "^EXCESSIVE SNOW$",
              "^(HEAVY SURF(/HIGH SURF)?|(HIGH|ROUGH) SEAS)$",
              "^SMALL HAIL$",
              "^MIXED PRECIP(ITATION)?$|^RAIN(/SNOW)?$")
replacements <- c("",
                  "THUNDERSTORM",
                  "HURRICANE (TYPHOON)",
                  "HURRICANE (TYPHOON)",
                  "FLOOD",
                  "",
                  "DEBRIS FLOW",
                  "STORM SURGE/TIDE",
                  "WILDFIRE",
                  "RIP CURRENT",
                  "EXTREME COLD/WIND CHILL",
                  "WINTER WEATHER",
                  "FROST/FREEZE",
                  "COASTAL FLOOD",
                  "COLD/WIND CHILL",
                  "DENSE FOG",
                  "STRONG WIND",
                  "HEAVY SNOW",
                  "HIGH SURF",
                  "HAIL",
                  "HEAVY RAIN")
data.frame(pattern = patterns, replacement = replacements)

df$EVTYPE <- mgsub(patterns, replacements, df$EVTYPE)
not.matched <- df$EVTYPE[!(df$EVTYPE %in% evtypes)]
df$EVTYPE[!(df$EVTYPE %in% evtypes)] <- "UNMATCHED"
length(not.matched)
sort(table(not.matched), decreasing = TRUE)

unique(df$EVTYPE)

str_trim(df$EVTYPE)
matches <- data.frame(permitted = evtypes, found = NA)
matches$found[39] <- c("TSTM WIND")


df2 <- df %>% 
    mutate_each(funs(as.character), EVTYPE) %>% 
    mutate(found = (EVTYPE %in% evtypes)) %>% 
    filter(found == FALSE)
sort(table(df2$EVTYPE))
unique(df2$EVTYPE)
e2 <- unique(df2$EVTYPE)
