rankall <- function(outcome, num = "best") {
    ## Read outcome data
    outcomes <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    
    ## Read states and check that outcome is valid
    states <- sort(unique(outcomes$State))
    n.states <- length(states)
    valid.outcomes <- c("heart attack", "heart failure", "pneumonia")
    if(!(outcome %in% valid.outcomes)) stop("invalid outcome")
    
    ## outcome column number
    col.outcome <- switch(outcome,
                          "heart attack"  = 11,  # "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack"
                          "heart failure" = 17,  # "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure"
                          "pneumonia"     = 23)  #"Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia"
    outcome <- gsub(" ", ".", outcome)

    ## For each state, find the hospital of the given rank
    ## Return a data frame with the hospital names and the
    ## (abbreviated) state name
    h <- character(n.states)
    o <- numeric(n.states)
    n.hospitals <- numeric(n.states)
    for(i in 1:n.states) {
#         if(i == n.states - 3) browser()
        state <- states[i]
        state.outcomes <- subset(outcomes, State == state)
        state.outcomes[outcome] <- suppressWarnings(as.numeric(state.outcomes[, col.outcome]))
        state.outcomes <- state.outcomes[complete.cases(state.outcomes), ]
        b <- state.outcomes[order(state.outcomes[outcome], state.outcomes$Hospital.Name), ]
        
        ## Determine rank
        n.h <- nrow(b)
        n.hospitals[i] <- n.h
        r <- num
        if(r == "best")  r <- 1
        if(r == "worst") r <- n.h
        if(r > n.h) {
            h[i] <- NA
            o[i] <- NA
        } else {
            h[i] <- b$Hospital.Name[r]
            o[i] <- b[r, outcome]
        }
    }
    
    df <- data.frame(hospital = h, state = states) #, n.hospitals = n.hospitals, outcome = o)
    row.names(df) <- states
    return(df)
}