best <- function(state, outcome) {
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
    
    ## Return hospital name in that state with lowest 30-day death
    ## rate
    outcomes <- subset(outcomes, State == state)   # "Hospital.Name", "State", col.outcome
    outcomes[outcome] <- suppressWarnings(as.numeric(outcomes[, col.outcome]))
    outcomes <- outcomes[complete.cases(outcomes), ]
    b <- outcomes[order(outcomes[outcome], outcomes$Hospital.Name), ]
    return(b$Hospital.Name[1])
}