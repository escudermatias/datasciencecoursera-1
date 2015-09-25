complete <- function(directory, id = 1:332) {
    ## 'directory' is a character vector of length 1 indicating
    ## the location of the CSV files
    
    ## 'id' is an integer vector indicating the monitor ID numbers
    ## to be used
    
    ## Return a data frame of the form:
    ## id nobs
    ## 1  117
    ## 2  1041
    ## ...
    ## where 'id' is the monitor ID number and 'nobs' is the
    ## number of complete cases
    n <- length(id)
    comp.cases <- data.frame(id = as.integer(), nobs = as.integer())
    for(i in 1:n) {
        mon.id <- id[i]
        fname <- file.path(directory, sprintf("%0.3d.csv", mon.id))
        df <- read.csv(fname, stringsAsFactors = FALSE)
        comp.cases[i, ] <- c(mon.id, sum(complete.cases(df)))
    }
    return(comp.cases)
}