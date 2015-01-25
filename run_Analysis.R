#Set working dir to where this script is
#Use source("run_analysis.R", chdir=T)

#pwd <- getwd()
#if (!is.null(pwd)) { 

#  setwd(pwd) 
#} else { 

#  print("Directory not found") 

#} 

#Create data folder if does not exist

if (!file.exists("data")){
  
  dir.create("data")
  
}

#Download and unzip raw data file

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

temp <- "./data/temp.zip"

download.file(fileURL,temp)
unzipped <- unzip(temp, exdir="./data")

# print(list.files("./data"))

unlink(temp)
#print(unzipped)


#Load train and test files into R

#library(data.table)
train.file <- unzipped[27]

test.file <- unzipped[15]

train.dt <- read.table(train.file,header=F,sep="")

test.dt <- read.table(test.file,header=F,sep="")


#Add names to columns

features.file <- unzipped[2]

features.dt <- read.table(features.file,sep="", header=F)

features <- as.character(features.dt$V2)

names(train.dt) <- features

names(test.dt) <- features


#Add column of activities
train.activities.file <- unzipped[28]

test.activities.file <- unzipped[16]

train.activities.dt <- read.table(train.activities.file,
                                  
                                  sep="", header=F)

names(train.activities.dt) <- "Activity"

test.activities.dt <- read.table(test.activities.file,
                                 
                                 sep="", header=F)

names(test.activities.dt) <- "Activity"


activities.file <- unzipped[1]

activities.dt <- read.table(activities.file,sep="", header=F)

train.activities.converted <- sapply(train.activities.dt,function(x) as.character(activities.dt$V2[x]))

test.activities.converted <- sapply(test.activities.dt,function(x) as.character(activities.dt$V2[x]))

train.dt$Activity <- as.character(train.activities.converted)

test.dt$Activity <- as.character(test.activities.converted)


#Add column of subjects

train.subjects.file <- unzipped[26]

test.subjects.file <- unzipped[14]

test.subjects.dt <- read.table(test.subjects.file,sep="", header=F)

train.subjects.dt <- read.table(train.subjects.file,sep="", header=F)

names(test.subjects.dt) <- "Subject"

names(train.subjects.dt) <- "Subject"


train.dt$Subject <- train.subjects.dt$Subject

test.dt$Subject <- test.subjects.dt$Subject


#Merging train and tet sets

#R automatically merges the frames by common variable names

train.test <- rbind(train.dt,test.dt)


#Extract features "mean" and "stdev" and keep them in a separate dataset

extract.colnames.mean <- names(train.test)[grep("mean()", names(train.dt))]

extract.colnames.std <- names(train.test)[grep("std()", names(train.dt))]

extract.colnames <- c(extract.colnames.mean,extract.colnames.std)

extract.train.test <- train.test[,extract.colnames]


#Create tidy dataset with avg of each column for each subject and activity

train.test.1 <- subset(train.test, select=-c(Activity, Subject))

aggdata <- aggregate(train.test.1, by=list(Subject=train.test$Subject, Activity=train.test$Activity), FUN=mean, na.rm=T)


write.table(aggdata, file="./data/smartphones-tidy.txt")

#To work with tables... some notes

#train.dt <- as.data.table(train.dt)
#test.dt <- as.data.table(test.dt)

#tables()
