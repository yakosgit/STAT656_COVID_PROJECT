packs = c('dplyr','ggplot2', 'caret','corrplot', 'e1071','readr', 'pROC')
lapply(packs,require,character.only=TRUE)

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
dataSet <- dataSet %>% filter(!is.na(res_state)
                              & !is.na(res_county) & !is.na(county_fips_code)
                              & !is.na(age_group) & !is.na(sex)
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

#making sure we have the correct reference category
YtrainRelevel = relevel(Ytrain, ref = 'No')
YtestRelevel = relevel(Ytest, ref = 'No')

#training our logistic elastic net model
set.seed(13)
K            = 10
trainControl = trainControl(method = "cv", number = K)
tuneGrid     = expand.grid('alpha'=c(0,.25,.5,.75,1),'lambda' = seq(00, .001, length.out = 30))

elasticOut = train(x = XtrainFull, y = YtrainRelevel,
                   method = "glmnet", 
                   trControl = trainControl, tuneGrid = tuneGrid)

#starting to look at the output from the model
elasticOut$finalModel$beta[,1:6]

#best tune from the model
elasticOut$bestTune

#alpha of 0 and a lambda of .001
#I'm pretty sure an alpha value of 0 is just a ridge regression

#refitting the model with the best parameters
require(glmnet)
glmnetOut      = glmnet(x = as.matrix(XtrainFull), y = YtrainRelevel, s=elasticOut$bestTune$alpha, 
                        family = 'binomial', standardize = FALSE)
probHatTest    = predict(glmnetOut, XtestFull, s=elasticOut$bestTune$lambda, type='response')
YhatTestGlmnet = ifelse(probHatTest > 0.035, 'Yes', 'No')

#looking at the coefficients from the best tune
betaHat = coef(glmnetOut, s=elasticOut$bestTune$lambda)
betaHat

#get the accuracy 
mean(YhatTestGlmnet == YtestRelevel)

probHatTest = predict(elasticOut, XtestFull, s=elasticOut$bestTune$lambda, type = 'prob')
rocOut = roc(response = YtestRelevel, probHatTest$Yes)

plot(rocOut)

rocOut$auc

confusionMatrixOut = confusionMatrix(reference = YtestRelevel, data = as.factor(YhatTestGlmnet))
confusionMatrixOut
