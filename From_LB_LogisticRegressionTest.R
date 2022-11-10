dataSetName = 'COVID-19_Case_Surveillance_Public_Use_Data_with_Geography_Filterd.csv'
dataSet     = read_csv(dataSetName)

#check to see what is missing
sapply(dataSet, function(x) sum(is.na(x)))

#drop some columns that we're not going to use
dataSet <- dataSet %>% select (-c(case_positive_specimen_interval, case_onset_interval,
                                  state_fips_code, ethnicity, res_county, county_fips_code, res_state))

#check again for missing data
sapply(dataSet, function(x) sum(is.na(x)))

#filtering out all these missings
dataSet <- dataSet %>% filter(
                              !is.na(age_group) & !is.na(sex)
                              & !is.na(race))

#check again for missing data
sapply(dataSet, function(x) sum(is.na(x)))

#we have some other 'missing' values
data <- dataSet %>% filter((age_group != 'Unknown' & age_group != 'Missing') &
                          (sex != 'Unknown' & sex != 'Missing') &
                          (race != 'Unknown' & race != 'Missing') &
                          (process != 'Unknown' & process != 'Missing') &
                          (exposure_yn != 'Missing') &
                          (symptom_status != 'Unknown' & symptom_status != 'Missing') &
                          (hosp_yn != 'Unknown' & hosp_yn != 'Missing') &
                          (icu_yn != 'Unknown' & icu_yn != 'Missing'))




table(data$age_group) #not horribly imbalanced
table(data$sex) #balanced
table(data$race) #fairly imbalanced
table(data$process) #some rare classes
table(data$exposure_yn) #pretty good
table(data$current_status) #fine
table(data$symptom_status) # no asymptomatic, might need to remove
table(data$hosp_yn) # fine
table(data$icu_yn) #yes is fairly rare
table(data$underlying_conditions_yn) #pretty good (maybe imbalanced in a biased way?)
table(data$death_yn) #imbalanced classification problem. Might need to look into this

#lets create some training and testing data
set.seed(13)
trainingDataIndex <- createDataPartition(data$death_yn, p=.7, list=FALSE)
trainingData <- data[trainingDataIndex,]
testingData <- data[-trainingDataIndex,]

#split into X and Y
Xtrain <- select(trainingData, -death_yn)
Xtest  <- select(testingData, -death_yn)
Ytrain <- factor(select(trainingData, death_yn) %>% unlist())
Ytest  <- factor(select(testingData, death_yn) %>% unlist())

#need to turn everything into dummy variables
dummyModel <- dummyVars(~ ., data= Xtrain, fullRank = TRUE)

XtrainFull = predict(dummyModel, Xtrain)
XtestFull = predict(dummyModel, Xtest)

#making the logistic regression model
YtrainRelevel = relevel(Ytrain, ref = 'Yes')
YtestRelevel = relevel(Ytest, ref = 'Yes')

trControl = trainControl(method = 'none')
outLogistic = train(x = XtrainFull, y = YtrainRelevel,
                    method = 'glm', trControl = trControl)
YhatTestProb = predict(outLogistic, XtestFull, type = 'prob')

#plotting the roc curve
rocCurve = roc(Ytest, YhatTestProb$Yes)

#plot the roc
plot(rocCurve, legacy.axes=TRUE)

rocCurve$auc

#playing around with the sensitivities and specificities
thresholds = rocCurve$thresholds
pt8 = max(which(rocCurve$sensitivities >= 0.80) )
threshold = thresholds[pt8]
specificity = rocCurve$specificities[pt8]
sensitivity = rocCurve$sensitivities[pt8]

YhatTestThresh = ifelse(YhatTestProb$Yes > threshold,
                        'Yes', 'No') %>% as.factor

confusionMatrixOut = confusionMatrix(reference = YtestRelevel, data = YhatTestThresh)
confusionMatrixOut