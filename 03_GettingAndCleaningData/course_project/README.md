# Getting and Cleaning Data Course Project

Scripts used in this project are:

* `get_data.R`
* `run_analysis.R`

This README documents what the scripts do.
Note that the scripts include commentary as well to make following the process easier.

## Getting the UCI Dataset

The script `get_data.R` downloads the UCI Dataset (contained in a zip archive) into a data subdirectory and unzips everything into that same directory.
This means that --after setting the working directory to the one that this README is sitting in-- the data will be accessible under the path `.data/UCI\ HAR\ Dataset`.
Note that we have to excape whitespace in the directory name.


## 
