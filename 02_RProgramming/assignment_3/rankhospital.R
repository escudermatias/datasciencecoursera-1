rankhospital <- function(state, outcome, num = "best") {
    ## Read outcome data
    outcomes <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    
    ## Check that state and outcome are valid
    valid.states <- unique(outcomes$State)
    valid.outcomes <- c("heart attack", "heart failure", "pneumonia")
    if(!(state %in% valid.states)) stop("invalid state")
    if(!(outcome %in% valid.outcomes)) stop("invalid outcome")
    
    ## outcome column number
    col.outcome <- switch(outcome,
                          "heart attack"  = 11,  # "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack"
                          "heart failure" = 17,  # "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure"
                          "pneumonia"     = 23)  #"Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia"
    outcome <- gsub(" ", ".", outcome)
    
    ## Return hospital name in that state with the given rank
    ## 30-day death rate
    outcomes <- subset(outcomes, State == state)   # "Hospital.Name", "State", col.outcome
    outcomes[outcome] <- suppressWarnings(as.numeric(outcomes[, col.outcome]))
    outcomes <- outcomes[complete.cases(outcomes), ]
    b <- outcomes[order(outcomes[outcome], outcomes$Hospital.Name), ]
    
    ## Determine rank
    n <- nrow(b)
    if(num == "best")  num <- 1
    if(num == "worst") num <- n
    if(num > n)  return(NA)
    
    return(b$Hospital.Name[num])
}