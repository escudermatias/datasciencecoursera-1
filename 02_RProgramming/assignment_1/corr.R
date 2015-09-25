corr <- function(directory, threshold = 0) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
    
    ## 'threshold' is a numeric vector of length 1 indicating the
    ## number of completely observed observations (on all
    ## variables) required to compute the correlation between
    ## nitrate and sulfate; the default is 0
    
    ## Return a numeric vector of correlations
    filenames <- list.files(directory, full.names = TRUE)
    corr.values <- NULL
    for(fname in filenames) {
        df <- read.csv(fname, stringsAsFactors = FALSE)
        if(sum(complete.cases(df)) > threshold) {
            corr.values <- c(corr.values, cor(df$nitrate, df$sulfate, use = "complete.obs"))
        }
    }
    return(corr.values)
}