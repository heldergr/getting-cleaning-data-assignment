# Getting and Cleaning Data Assignment

In this file I describe what I implemented to get the tidy data set as requested for this assignment.

First I wrote an utility function to return the activity label from a specific index based on a data set I extracted from the "features.txt" file.

```{r eval=false}
getActivityLabel <- function(activityLabels, index) {
    activityLabels[index, 2]
}
```

## Load and filter data from test files

In the following step I loaded the test data (including, subject, test set and features) into data frames.

```{r eval=false}
subjectTest <- read.table("./test/subject_test.txt")
xTest <- read.table("./test/X_test.txt")
yTest <- read.table("./test/y_test.txt")
```

So I extracted the train data (like the previous step it included subject, test set and features) into data frames.

```{r eval=false}
subjectTrain <- read.table("./train/subject_train.txt")
xTrain <- read.table("./train/X_train.txt")
yTrain <- read.table("./train/y_train.txt")
```

Load the activity labels so I can show them in the tidy data set.
```{r eval=false}
activityLabels <- read.table("./activity_labels.txt")
```

I needed to load the features data in order to show the column names for the measures and also to filter those that are related to mean and standard deviation.
```{r eval=false}
features <- read.table("./features.txt")
```

Filter the features keeping only index and name of those that are related to mean of standard deviation
```{r eval=false}
meanOrStdFeatures <- features[grepl("mean|Mean|std", features$V2),]
```

## 1. Merges the training and the test sets to create one data set.

Join test and train subjects to a single data frame.
```{r eval=false}
subject <- do.call(rbind, list(subjectTest, subjectTrain))
```

Join test and train test sets to a single data frame.
```{r eval=false}
x <- do.call(rbind, list(xTest, xTrain))
```

In the resulting test sets I keep in the data frame only the columns that are related to mean or standard deviation. Its necessary for the step 2 (Extracts only the measurements on the mean and standard deviation for each measurement).

```{r eval=false}
meanOrStdTests <- x[, meanOrStdFeatures$V1]
colnames(meanOrStdTests) <- meanOrStdFeatures$V2
```

Join test and train features to a single data frame.
```{r eval=false}
y <- do.call(rbind, list(yTest, yTrain))
```

Joing subject, feature and test data frames to a single data frame.
```{r eval=false}
df <- cbind(subject$V1, y$V1, meanOrStdTests)
```

## 3. Uses descriptive activity names to name the activities in the data set
A used the utility function defined before to get the name of an activity and used the transform function to change the Activity columns from its index to its descriptive name.
```{r eval=false}
colnames(df)[1] <- "Subject"
colnames(df)[2] <- "Activity"
df$Activity <- getActivityLabel(activityLabels, df$Activity)
```

## 4. Appropriately label the data set with descriptive variables names. Done before
Subject and Activity are already with descriptive names because I set them when created the whole data frame with this code (df <- data.frame(Subject = subject$V1, Activity = y$V1, tests = meanOrstdTests)). So I changed the name of the measure columns removing the "tests." prefix and the t or f prefix from the measures.
```{r eval=false}
oldColnames <- colnames(df)
newColnames <- gsub("^t", "time", oldColnames)
newColnames <- gsub("^f", "freq", newColnames)
colnames(df) <- newColnames
```

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Previously I loaded the reshape2 package, which I used to melt and cast back the data sets to have the final result.
```{r eval=false}
library(reshape2)
```

Here I used the melt functions letting Subject and Activity as ids so this way Ill all the other columns as variables.
```{r eval=false}
b <- melt(df, id=c("Subject", "Activity"), measure.vars = colnames(df)[3:81])
```

So I did the cast back the data frame having grouping by Subject and Activity and so creating one column per each measure and the values are the average of that measure for the specific Subject and Activity.
```{r eval=false}
ms <- dcast(b,  Subject + Activity ~ variable, mean)
View(ms)
```

Write the data set result.
```{r eval=false}
write.table(ms, "tidydataset.txt", row.names = F)
```
