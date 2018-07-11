# Utility functions
getActivityLabel <- function(activityLabels, index) {
    activityLabels[index, 2]
}

# Load test data
subjectTest <- read.table("./test/subject_test.txt")
xTest <- read.table("./test/X_test.txt")
yTest <- read.table("./test/y_test.txt")

# Load trainng data
subjectTrain <- read.table("./train/subject_train.txt")
xTrain <- read.table("./train/X_train.txt")
yTrain <- read.table("./train/y_train.txt")

# Load activity labels
activityLabels <- read.table("./activity_labels.txt")

# Filter features to keep only the mean and std.
features <- read.table("./features.txt")
meanOrStdFeatures <- features[grepl("mean|Mean|std", features$V2),]

# 1. Merges the training and the test sets to create one data set.

# Join test and train subjects
subject <- do.call(rbind, list(subjectTest, subjectTrain))

# Join test and train test sets
x <- do.call(rbind, list(xTest, xTrain))

# Filter test sets columns to keep only the mean and std
meanOrStdTests <- x[, meanOrStdFeatures$V1]
colnames(meanOrStdTests) <- meanOrStdFeatures$V2

# Join test and train features
y <- do.call(rbind, list(yTest, yTrain))

# Joing subject, feature and test in one data set
# df <- data.frame(Subject = subject$V1, Activity = y$V1, tests = meanOrstdTests)
df <- cbind(subject$V1, y$V1, meanOrStdTests)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# Done when filtering the columns by the index of the measures

# 3. Uses descriptive activity names to name the activities in the data set
# df <- transform(df, Activity = getActivityLabel(activityLabels, Activity))
colnames(df)[1] <- "Subject"
colnames(df)[2] <- "Activity"
df$Activity <- getActivityLabel(activityLabels, df$Activity)

# 4. Appropriately label the data set with descriptive variables names. Done before
oldColnames <- colnames(df)
newColnames <- gsub("^t", "time", oldColnames)
newColnames <- gsub("^f", "freq", newColnames)
colnames(df) <- newColnames

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)

# Melt data to have every measure specific for a subject and feature pair
b <- melt(df, id=c("Subject", "Activity"), measure.vars = colnames(df)[3:81])

# Cast the melted data to have every measure mean by feature and subject
ms <- dcast(b,  Subject + Activity ~ variable, mean)
View(ms)

write.table(ms, "tidydataset.txt", row.names = F)
