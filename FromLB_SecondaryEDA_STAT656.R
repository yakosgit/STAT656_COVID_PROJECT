###SET WORKING DIRECTORY TO SAME FOLDER AS RDATA OBJECT###

##loading packages
packs = c('dplyr','ggplot2', 'caret','corrplot', 'e1071','readr', 'pROC')
lapply(packs,require,character.only=TRUE)

#read in the Rdata object that has the filtered data based on the death_yn column
load('COVID_Data.Rdata')

#take a look at the columns that we have in the dataset
str(data)

#find out where we still have some missing data
which(apply(data, 2, anyNA))

#filter out rows where we don't have data for underlying conditions
table(data$underlying_conditions_yn)

data <- data %>% filter(!is.na(underlying_conditions_yn))
#this gives us 1,477,201 rows

#how many rows to we end up with if we filter out all of the missings we have

data <- data %>% filter(!is.na(res_state) & !is.na(state_fips_code)
                        & !is.na(res_county) & !is.na(county_fips_code)
                        & !is.na(age_group) & !is.na(sex)
                        & !is.na(race) & !is.na(ethnicity)
                        & !is.na(case_positive_specimen_interval) 
                        & !is.na(case_onset_interval))
#this gives us 775,712 rows, which really isn't that bad

#looking at the structure again
str(data)

#we have some other 'missing' values
data <- data %>% filter((age_group != 'Unknown' & age_group != 'Missing') &
                        (sex != 'Unknown' & sex != 'Missing') &
                        (race != 'Unknown' & race != 'Missing') &
                        (ethnicity != 'Unknown' & ethnicity != 'Missing') &
                        (process != 'Unknown' & process != 'Missing') &
                        (exposure_yn != 'Missing') &
                        (symptom_status != 'Unknown' & symptom_status != 'Missing') &
                        (hosp_yn != 'Unknown' & hosp_yn != 'Missing') &
                        (icu_yn != 'Unknown' & icu_yn != 'Missing'))

#now removing all of these missing, we have 114,540 rows (which is still pretty good)
114540 / 86000000
#but I don't know if we should throw away 99.98% of our data??

#anyway, let's see what we've got
str(data)

table(data$res_state) #probably not going to need this
table(data$age_group) #not horribly imbalanced
table(data$sex) #balanced
table(data$race) #fairly imbalanced
table(data$ethnicity) #imbalanced
table(data$process) #some rare classes
table(data$exposure_yn) #pretty good
table(data$current_status) #fine
table(data$symptom_status) # no asymptomatic, might need to remove
table(data$hosp_yn) # fine
table(data$icu_yn) #yes is fairly rare
table(data$underlying_conditions_yn) #pretty good (maybe imbalanced in a biased way?)
table(data$death_yn) #imbalanced classification problem. Might need to look into this


#looking at the date column 
data$year <- substr(data$case_month, 1, 4)
data$month <- substr(data$case_month, 6, 8)

table(data$year)
table(data$month)

#test changes2 - delete
#test changes3 - delete