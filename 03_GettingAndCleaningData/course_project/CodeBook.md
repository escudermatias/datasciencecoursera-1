# Codebook

## The Original UCI Dataset

The **Human Activity Recognition Using Smartphones Dataset** is available from the UC Irvine Machine Learning Repository (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

The dataset was originally built by Reyes-Ortiz and colleagues from recordings of 30 subjects performing activities of daily living while carrying a waist-mounted smartphone with embedded inertial sensors.

The script `get_data.R` downloads the UCI Dataset (contained in a zip archive) into a data subdirectory and unzips everything into that same directory.
This means that --after setting the working directory to the one that this README is sitting in-- the data is accessible under the path `./data/UCI\ HAR\ Dataset`.


### Dataset Description and Documentation

The UCI dataset contains several files documenting the data.
As we (in good old scientific tradition, I am using the plural "we" in this document although I have done the project solely on my own) used these files to understand the structure of the dataset, we list the relevant information here:

* `README.txt` explains who collected the data, how it was collected, gives an **overview** of the data recorded, and lists the files contained in the dataset
* `activity_labels.txt` lists the 6 **activities** (and their class labels, 1 to 6) during which the smartphone data was recorded
* `features.txt` lists all the 561 **feature variables** (and their factor variables, 1 to 561) that were calculated from the original recordings
* `features_info.txt` describes in more depth how the data was recorded and how the different features were calculated.

The test subjects were divided into a training and a test subset.
The dataset contains data for these two sets in two subdirectories, `train` and `test`.
The actual data is found in the following `.txt` files:

* `./data/UCI\ HAR\ Dataset/train/X_train.txt`: Training set
* `./data/UCI\ HAR\ Dataset/train/y_train.txt`: Training labels
* `./data/UCI\ HAR\ Dataset/train/subject_train.txt`: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
* `./data/UCI\ HAR\ Dataset/test/X_test.txt`: Test set
* `./data/UCI\ HAR\ Dataset/test/y_test.txt`: Test labels
* `./data/UCI\ HAR\ Dataset/test/subject_train.txt`: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

According to the `README.txt` file, the following are the components of the feature vector recorded (where XYZ means that there are actually three features, one for each of the cartesian axes):

tBodyAcc-XYZ, tGravityAcc-XYZ, tBodyAccJerk-XYZ, tBodyGyro-XYZ, tBodyGyroJerk-XYZ, tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag, fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccMag, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag

For each feature, a set of different variables was calculated (mean, standard deviation, median absolute deviation, largest value, ...).
The values for each of these calculated variables for each feature are contained in the files `X_train.txt` and `X_test.txt`
Feature variables are normalized and bounded within [-1,1], and "each feature vector is a row on the text file".
The files `y_train.txt` and `y_test.txt` contain the according activities performed by each subject and the files `subject_train.txt` and `subject_test.txt` give the subject ID's.

The assigment states that step 2 should extract **"only the measurements on the mean and standard deviation for each measurement"**.
I.e., of all the estimated variables we only need the ones containing the character stings `mean()` or `std()`.
In our understanding, the mean and standard deviation for each measurement should go together which excludes variables such as the ones containing `meanFreq` or `gravityMean` as there is no standard deviation measurement associated with these variables.

For both the training and the test sets, there are also inertial signal recordings available.
But, as we just have argued above, because the assignment states that only "the mean and standard deviation for each measurement" should be extracted anyway, we will ignore the `Inertial Signals` folders of the training and test subsets (note that this was also suggested by David Hood (https://class.coursera.org/getdata-015/forum/thread?thread_id=26) on the Coursera community forums.)


# Merging the Training and Test Datasets

*Note that the `run_analysis.R` script contains a lot of commentary explaining the code, more or less line by line.*

Also note that we deviate slightly from the 5 steps listed in the assignment as it seemed a little easier (and less errorprone?) to name the variables and activities properly before merging the datasets.

But the major steps performed are the following (labeled A to H here):

**A.** Read in the activities data from the file `activity_labels.txt`, do some minor processing:
    
* Apply lowercase to all labels.
* Remove the "waling_" prefix for the stairs activities (makes for labels of approx. the same length for all activities).
    
**B.** Read in the variable names from the file `features.txt`.

**C.** Read in the **test** data from the file `X_test.txt`, using the `LaF` package for fast reading of fixed width format files. Process as follows:

* Turn all columns into numeric format.
* Name the columns with the variable names from the step 2.
* Add a column for the subject ID's from the file `subject_test.txt`
* Add a column for the activities from step 1.
* Add a column signifying membership to the test group group (for a later join with the training dataset).

**D.** Read in the **training** data from the file `X_train.txt`, using the `LaF` package for fast reading of fixed width format files. Process as follows:

* Turn all columns into numeric format.
* Name the columns with the variable names from the step 2.
* Add a column for the subject ID's from the file `subject_train.txt`
* Add a column for the activities from step 1.
* Add a column signifying membership to the training group group (for a later join with the test dataset).

**E.** Merge the two datasets from steps 3 and 4 by row binding them. Process slightly:

* Turn columns for subject ID, activity, and group into factor variables.

**F.** Select only the mean and standard deviation columns, using `dplyr::select` with regular expression matching.

**G.** Rename the variables:

* Apply lowercase.
* Remove dashes and parentheses.

**H.** Group the merged dataset by subject and activity, then calculate the mean for each measurement columns. Using `dplyr::group_by` and `dplyr::summarise_each`, then:

* Write the resulting dataset (`xsummarised`) to a text file.


## The Resulting Tidy Dataset

The resulting dataset has 180 observations of 68 variables. The variables are:

* subjectid: Denotes the subject ID (integer values 1-30)
* activity: Denotes the activity performed (i.e. one of the following: laying, sitting, standing, walking, downstairs (i.e. walking downstairs), or upstairs (i.e. walking upstairs))
* The remaining 66 columns contain mean values (for the subject given and the activity stated) of 66 different measurements. All column names are formed analogously to the example given for the first of the following columns):
    * tbodyaccmeanx: The mean value of the measurement "tBodyAcc-mean()-X" for the given subject during the stated activity
    * tbodyaccmeany
    * tbodyaccmeanz
    * tbodyaccstdx
    * tbodyaccstdy
    * tbodyaccstdz
    * tgravityaccmeanx
    * tgravityaccmeany
    * tgravityaccmeanz
    * tgravityaccstdx
    * tgravityaccstdy
    * tgravityaccstdz
    * tbodyaccjerkmeanx
    * tbodyaccjerkmeany
    * tbodyaccjerkmeanz
    * tbodyaccjerkstdx
    * tbodyaccjerkstdy
    * tbodyaccjerkstdz
    * tbodygyromeanx
    * tbodygyromeany
    * tbodygyromeanz
    * tbodygyrostdx
    * tbodygyrostdy
    * tbodygyrostdz
    * tbodygyrojerkmeanx
    * tbodygyrojerkmeany
    * tbodygyrojerkmeanz
    * tbodygyrojerkstdx
    * tbodygyrojerkstdy
    * tbodygyrojerkstdz
    * tbodyaccmagmean
    * tbodyaccmagstd
    * tgravityaccmagmean
    * tgravityaccmagstd
    * tbodyaccjerkmagmean
    * tbodyaccjerkmagstd
    * tbodygyromagmean
    * tbodygyromagstd
    * tbodygyrojerkmagmean
    * tbodygyrojerkmagstd
    * fbodyaccmeanx
    * fbodyaccmeany
    * fbodyaccmeanz
    * fbodyaccstdx
    * fbodyaccstdy
    * fbodyaccstdz
    * fbodyaccjerkmeanx
    * fbodyaccjerkmeany
    * fbodyaccjerkmeanz
    * fbodyaccjerkstdx
    * fbodyaccjerkstdy
    * fbodyaccjerkstdz
    * fbodygyromeanx
    * fbodygyromeany
    * fbodygyromeanz
    * fbodygyrostdx
    * fbodygyrostdy
    * fbodygyrostdz
    * fbodyaccmagmean
    * fbodyaccmagstd
    * fbodybodyaccjerkmagmean
    * fbodybodyaccjerkmagstd
    * fbodybodygyromagmean
    * fbodybodygyromagstd
    * fbodybodygyrojerkmagmean
    * fbodybodygyrojerkmagstd

That's all he wrote.

