library(dplyr)
library(reshape)
library(ggplot2)
library(rpart)
library(caret)
library(rattle)

setwd("C:/Users/elain/Desktop/New Skills/HOS_20161219_cleaned")
list.files()

# select useful folders to investigate meaningful information for ranking
complications <- read.csv("Complications - Hospital.csv")
HCAHPS <- read.csv("HCAHPS - Hospital.csv")
HAI <- read.csv("Healthcare Associated Infections - Hospital.csv")
general <- read.csv("Hospital General Information.csv")
MHSP <- read.csv("Medicare Hospital Spending per Patient - Hospital.csv")
RD <- read.csv("Readmissions and Deaths - Hospital.csv")
TEC <- read.csv("Timely and Effective Care - Hospital.csv")

# for each data set, look at the variables and data summary to pick up valuable variables for ranking
general <- subset(general, select = c(Provider.ID, Hospital.overall.rating))
colnames(general) <- c("Provider.ID", "overall.rating")
# complications <- subset(complications, select = c(Provider.ID, Measure.ID, Score))
# HCAHPS <- subset(HCAHPS, select = c(Provider.ID, HCAHPS.Measure.ID, Patient.Survey.Star.Rating))
# HAI <- subset(HAI, select = c(Provider.ID, Measure.ID, Score))
# MHSP <- subset(MHSP, select = c(Provider.ID, Measure.ID, Score))
# RD <- subset(RD, select = c(Provider.ID, Measure.ID, Score))
# TEC <- subset(TEC, select = c(Provider.ID, Measure.ID, Score))

# since each hospital has multiple measurements and scores for every measure discription, in order to 
# put all the data into a single dataframe, here all the scores are converted to a mean value. 
# The fisrt advantage of this transformation is reducing data redundancy, the second one is to make 
# sure every hospital have bigger possibility to have a value for every measurement. In the mean time. 
# data structure will be more uniformed and makes the following modeling easier.
complications$Score = as.numeric(as.character(complications$Score))
complications = na.omit(complications)
comp_hospital = complications %>% group_by(Provider.ID) %>% summarise(comp_mean = mean(Score))

HCAHPS$Patient.Survey.Star.Rating = as.numeric(HCAHPS$Patient.Survey.Star.Rating)
HCAHPS = na.omit(HCAHPS)
HCAHPS_hospital = HCAHPS %>% group_by(Provider.ID) %>% summarise(patient_rating = mean(Patient.Survey.Star.Rating))

HAI$Score = as.numeric(as.character(HAI$Score))
HAI = na.omit(HAI)
HAI_hospital = HAI %>% group_by(Provider.ID) %>% summarise(hai_mean = mean(Score))

MHSP$Score = as.numeric(as.character(MHSP$Score))
MHSP = na.omit(MHSP)
MHSP_hospital = MHSP %>% group_by(Provider.ID) %>% summarise(mhsp_mean = mean(Score))

RD$Score = as.numeric(as.character(RD$Score))
RD = na.omit(RD)
RD_hospital = RD %>% group_by(Provider.ID) %>% summarise(rd_mean = mean(Score))

TEC$Score = as.numeric(as.character(TEC$Score))
TEC = na.omit(TEC)
TEC_hospital = TEC %>% group_by(Provider.ID) %>% summarise(tec_mean = mean(Score))

data = merge_recurse(list(general, comp_hospital, HCAHPS_hospital, HAI_hospital, MHSP_hospital, 
                          RD_hospital, TEC_hospital), by = "Provider.ID")

# Here a dataframe with 4870 observations selected from 4807 hospitals have been created, with 6 variables to measure
# the score or ranking of each description and 1 overall rating.
# The analysis start with linear regression.
# First, make a plot to look at the linear relationship among the variables
data$overall.rating = as.numeric(data$overall.rating)
pairs(data[-1])
# There're no significant linear relationship among the variables, and the overall rating show random, wide distribution in each rating level.
# Since the linear correlation is not significant, and overall rating is factor type, which is hard to predict with linear model, a random forest will be performed.
# First, the dataset is split into training and testing set by 0.66:0.34 ratio.
data$overall.rating = as.factor(data$overall.rating)
data = subset(data[-1])
data = na.omit(data)
inTrain = createDataPartition(data$overall.rating, p = 0.66, list = FALSE)
training = data[inTrain, ]
testing = data[-inTrain, ]

rf = randomForest(y = training$overall.rating, x = training[-1], 
                  ytest = testing$overall.rating, xtest = testing[-1],
                  ntree = 70, mtry = 2, keep.forest = TRUE)
# the overall accuracy for mtry = 2 is 0.64. Enhancement can be done for selecting different variables from the dataset.
# predicting new result with testing set with the fitted model
varImpPlot(rf, type = 2)

tree = rpart(data$overall.rating ~ ., data[-1], control = rpart.control(maxdepth = 3))
tree
