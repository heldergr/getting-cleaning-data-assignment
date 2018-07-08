# getting-cleaning-data-assignment
Repository for the Getting and Cleaning Data Assignment.

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
df <- data.frame(Subject = subject$V1, Activity = y$V1, tests = meanOrstdTests)
```

# 3. Uses descriptive activity names to name the activities in the data set
```{r eval=false}
df <- transform(df, Activity = getActivityLabel(activityLabels, Activity))
```

# 4. Appropriately label the data set with descriptive variables names. Done before
```{r eval=false}
oldColnames <- colnames(df)
newColnames <- gsub("tests.[t|f]", "", oldColnames)
colnames(df) <- newColnames
```

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```{r eval=false}
library(reshape2)
```

# Melt data to have every measure specific for a subject and feature pair
```{r eval=false}
b <- melt(df, id=c("Subject", "Activity"), measure.vars = colnames(df)[3:81])
```

# Cast the melted data to have every measure mean by feature and subject
```{r eval=false}
ms <- dcast(b,  Subject + Activity ~ variable, mean)
View(ms)
```

```{r eval=false}
write.table(ms, "tidydataset.txt", row.names = F)
```

## How to load the tidy data set 
