# Getting and Cleaning Data Course Project

This repository contains the course project analysis from Coursera's "Getting and Cleaning Data" class.

The analysis revolves around a **Human Activity Recognition Using Smartphones Dataset** available from the UC Irvine Machine Learning Repository (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).
The dataset was originally built by Reyes-Ortiz and colleagues from recordings of 30 subjects performing activities of daily living while carrying a waist-mounted smartphone with embedded inertial sensors.

This README explains how the two scripts in this repository work and how they are connected.
To fully reproduce the analysis, save them in a directory on your computer.
Run `get_data.R` first, as `run_analysis.R` expects to find the data in specific locations.

1. `get_data.R`
:   Downloads and unzips the data into a subdirectory `./data`.
2. `run_analysis.R`
:   Runs the analysis according to the steps 1 to 5 given in the assignment.
    Note that to run the analysis you will need the following packages:  
    `data.table`, `LaF`, `dplyr`, `stringr`


The analysis produces a tidy dataset named `xsummarised` and writes it to a text file, `tidy_dataset.txt`.
This file is also included in this repository.
That means you can also read the tidy dataset back in without running the analysis:
`xsummarised <- read.table("tidy_dataset.txt", header = TRUE, sep = " ")`

The tidy dataset contains 180 observations of 68 variables:

* The first column denotes the subject ID (integer values 1-30)
* The second column denotes the activity performed. I.e. one of the following:
    * laying
    * sitting
    * standing
    * walking
    * downstairs (i.e. walking downstairs)
    * upstairs (i.e. walking upstairs)
* All other columns contain mean values (for the subject given by the ID while performing the activity stated) of 66 different measurements.

The data is documented in more detail in the `CodeBook.md` file also included in this repository.
