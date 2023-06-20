# Set-up script for open label MDD TMS analysis

setwd("L:/Lab_JamesR/lachlanW/QNC_MDD_analysis/QNC_outcomes")

library(readxl)
library(dplyr)
library(magrittr)
library(tidyr)
library(ggplot2)

# setting up code to run on random sample, after final data collection, can remove slice_sample
sample_df <- read_excel("data/220901 Anonymised QNC Clinical Data.xlsx", sheet = 1, n_max = 57) %>% slice_sample(n = 10)
## ## ## double check nmax when reading in

data_df <- sample_df

table(data_df$`Research Tier (1 = Acceptable for typical RCT, 2 = Naturalistic Population only, 3 = Bipolar or neurological disorder)`)

data_df %$% table(`Research Tier (1 = Acceptable for typical RCT, 2 = Naturalistic Population only, 3 = Bipolar or neurological disorder)`,`Primary MDD (1  =  Yes, 2 = Secondary, Bipolar depression = 3)`) 

## Descriptive statistics of deomographics ####

# need to clarrify what the tier system is

data_df %<>% mutate(Age = as.numeric(Age))

data_df %>% summarise(
  mean_age = mean(Age),
  sd_age = sd(Age),
  median_age = median(Age),
  Q1_age = quantile(Age,0.25),
  Q3_age = quantile(Age,0.75),
  mean_edu = mean(`Years_of_Education (years)`),
  sd_edu = sd(`Years_of_Education (years)`),
  median_edu = median(`Years_of_Education (years)`),
  Q1_edu = quantile(`Years_of_Education (years)`,0.25),
  Q3_edu = quantile(`Years_of_Education (years)`,0.75),
)


data_df %$% table(`Gender(F=1,M=2)`)
data_df %$% table(`Handedness(R=1,L=2)`)
#data_df %$% table(`Treatment Resistant Depression (1 = Yes, 2 = No)`)
data_df %$% table(`1= Treatment MDD, 2= Bipolar`)
data_df %$% table(`Primary MDD (1  =  Yes, 2 = Secondary, Bipolar depression = 3)`)
data_df %$% table(`Research Tier (1 = Acceptable for typical RCT, 2 = Naturalistic Population only, 3 = Bipolar or neurological disorder)`)
data_df %$% table(`Referrer (1 = GP, 2 = Psychiatrist)`)
# data_df %$% table(Gender)
# data_df %$% table(Gender)
# data_df %$% table(Gender)
# data_df %$% table(Gender)

## will add checks for assumptions and conditions for anaysis once final data is sorted

#### df for analysis ####

data_df_anl <- data_df %>%
  mutate(GroupTier = factor(`Research Tier (1 = Acceptable for typical RCT, 2 = Naturalistic Population only, 3 = Bipolar or neurological disorder)`,
                            levels = c(1,2,3),
                            labels = c("RCT Acceptable", "Naturalistic Population", "Bipolar or Neurological Disorder"))
         )

GroupTierLevels = c("RCT Acceptable", "Naturalistic Population", "Bipolar or Neurological Disorder")


### outcomes of interest ####
# PRE-HAMA_Total"                         # HAMA                                         
# PRE-HAMA_Overall_Severity"
# POST-HAMA_Total                                                       
# POST-HAMA_Overall_Severity   
# PRE-MADRS_Total                         # MADRS                              
# PRE-MADRS_Overall_Severity     
# POST-MADRS_Total                                                      
# POST-MADRS_Overall_Severity 
# Anx_total-PRE                           # HADS 
# Dep_Total-PRE               
# Anxiety_Index_of_Overall_Severity -PRE                                          
# Dep_Index_of_Overall_Severity-PRE      
# Anx_total-W1                                                                    
# Dep_Total-W1                                            
# Anxiety_Index_of_Overall_Severity -W1                                           
# Dep_Index_of_Overall_Severity-W1
# Anx_total-W2                                                                    
# Dep_Total-W2                                            
# Anxiety_Index_of_Overall_Severity -W2                                           
# Dep_Index_of_Overall_Severity-W2    
# Anx_total-W3                                                                    
# Dep_Total-W3                                            
# Anxiety_Index_of_Overall_Severity -W3                                           
# Dep_Index_of_Overall_Severity-W3  
# Anx_total-W4                                                                  
# Dep_Total-W4                                             
# Anxiety_Index_of_Overall_Severity-W4                                            
# Dep_Index_of_Overall_Severity-W4   
# Anx_total-POST                                                                  
# Dep_Total-POST                                           
# Anxiety_Index_of_Overall_Severity-POST
# Dep_Index_of_Overall_Severity-POST    

#### MADRS ####

# analysis data set
data_df_anl_MADRS <- data_df_anl %>% 
  select(Participant_Number,GroupTier,`PRE-MADRS_Total`,`POST-MADRS_Total`) %>%
  pivot_longer(c(`PRE-MADRS_Total`,`POST-MADRS_Total`), names_to = "Time_Measure", values_to = "MADRS") %>%
  mutate(Time = if_else(grepl("PRE",Time_Measure),1,
                        if_else(grepl("POST",Time_Measure),2,0))) %>%
  mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_MADRS %>% group_by(GroupTier, Time) %>% summarise(meanMADRS = mean(MADRS),
                                                              sdMADRS = sd(MADRS),
                                                              minMADRS = min(MADRS),
                                                              maxMADRS = max(MADRS))
# plot
data_df_anl_MADRS %>% 
  ggplot(aes(x = MADRS)) + geom_histogram() + facet_grid(GroupTier~Time, scales="free")

# describe numeric difference
data_df_anl_MADRS %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(clinical = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(GroupTier) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqClinical = sum(clinical),
            percClinical = freqClinical/n(),
            freqRemission = sum(remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_MADRS %>% aov(MADRS ~ GroupTier*Time + Error(Participant_Number), data = .) %>% summary()

# single t tests
data_df_anl_MADRS %>% filter(GroupTier == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_MADRS %>% filter(GroupTier == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_MADRS %>% filter(GroupTier == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)



#### HAMA ####

# analysis data set
data_df_anl_HAMA <- data_df_anl %>% 
  select(Participant_Number,GroupTier,`PRE-HAMA_Total`,`POST-HAMA_Total`) %>%
  pivot_longer(c(`PRE-HAMA_Total`,`POST-HAMA_Total`), names_to = "Time_Measure", values_to = "HAMA") %>%
  mutate(Time = if_else(grepl("PRE",Time_Measure),1,
                        if_else(grepl("POST",Time_Measure),2,0))) %>%
  mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_HAMA %>% group_by(GroupTier, Time) %>% summarise(meanHAMA = mean(HAMA),
                                                             sdHAMA = sd(HAMA),
                                                             minHAMA = min(HAMA),
                                                             maxHAMA = max(HAMA))
# plot
data_df_anl_HAMA %>% 
  ggplot(aes(x = HAMA)) + geom_histogram() + facet_grid(GroupTier~Time, scales="free")

# describe numeric difference
data_df_anl_HAMA %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(clinical = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(GroupTier) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqClinical = sum(clinical),
            percClinical = freqClinical/n(),
            freqRemission = sum(remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_HAMA %>% aov(HAMA ~ GroupTier*Time + Error(Participant_Number), data = .) %>% summary()

# single t tests
data_df_anl_HAMA %>% filter(GroupTier == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HAMA %>% filter(GroupTier == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HAMA %>% filter(GroupTier == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)




#### HADS Dep ####

# analysis data set
data_df_anl_HDEP <- data_df_anl %>% 
  select(Participant_Number,GroupTier,`Dep_Total-PRE`,`Dep_Total-W1`,`Dep_Total-W2`,`Dep_Total-W3`,`Dep_Total-W4`,`Dep_Total-POST`) %>%
  pivot_longer(c(`Dep_Total-PRE`,`Dep_Total-W1`,`Dep_Total-W2`,`Dep_Total-W3`,`Dep_Total-W4`,`Dep_Total-POST`), 
               names_to = "Time_Measure", values_to = "HDEP") %>%
  mutate(Time = factor(gsub("Dep_Total-","",Time_Measure),
                       levels = c("PRE","W1","W2","W3","W4","POST"),
                       labels = c("Pre","W1","W2","W3","W4","Post"))) %>%
  mutate(HDEP = as.numeric(HDEP))
  # mutate(Time = if_else(grepl("PRE",Time_Measure),1,
  #                       if_else(grepl("POST",Time_Measure),2,0))) %>%
  # mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_HDEP %>% group_by(GroupTier, Time) %>% summarise(meanHDEP = mean(HDEP),
                                                             sdHDEP = sd(HDEP),
                                                             minHDEP = min(HDEP),
                                                             maxHDEP = max(HDEP))
# plot
data_df_anl_HDEP %>% 
  ggplot(aes(x = HDEP)) + geom_histogram() + facet_grid(GroupTier~Time, scales="free")
data_df_anl_HDEP %>% 
  ggplot(aes(x = HDEP)) + geom_histogram() + facet_grid(Time~GroupTier, scales="free")

data_df_anl_HDEP %>% 
  ggplot(aes(x = Time, y = HDEP, group = Participant_Number, colour = Participant_Number)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~GroupTier)

# describe numeric difference
data_df_anl_HDEP %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(clinical = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(GroupTier) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqClinical = sum(clinical),
            percClinical = freqClinical/n(),
            freqRemission = sum(remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_HDEP %>% aov(HDEP ~ GroupTier*Time + Error(Participant_Number), data = .) %>% summary()

# single t tests
data_df_anl_HDEP %>% filter(GroupTier == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HDEP %>% filter(GroupTier == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HDEP %>% filter(GroupTier == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

#### HADS Anx ####

# analysis data set
data_df_anl_HANX <- data_df_anl %>% 
  select(Participant_Number,GroupTier,`Anx_total-PRE`,`Anx_total-W1`,`Anx_total-W2`,`Anx_total-W3`,`Anx_total-W4`,`Anx_total-POST`) %>%
  pivot_longer(c(`Anx_total-PRE`,`Anx_total-W1`,`Anx_total-W2`,`Anx_total-W3`,`Anx_total-W4`,`Anx_total-POST`), 
               names_to = "Time_Measure", values_to = "HANX") %>%
  mutate(Time = factor(gsub("Anx_total-","",Time_Measure),
                       levels = c("PRE","W1","W2","W3","W4","POST"),
                       labels = c("Pre","W1","W2","W3","W4","Post"))) %>%
  mutate(HANX = as.numeric(HANX))
# mutate(Time = if_else(grepl("PRE",Time_Measure),1,
#                       if_else(grepl("POST",Time_Measure),2,0))) %>%
# mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_HANX %>% group_by(GroupTier, Time) %>% summarise(meanHANX = mean(HANX),
                                                             sdHANX = sd(HANX),
                                                             minHANX = min(HANX),
                                                             maxHANX = max(HANX))
# plot
data_df_anl_HANX %>% 
  ggplot(aes(x = HANX)) + geom_histogram() + facet_grid(GroupTier~Time, scales="free")
data_df_anl_HANX %>% 
  ggplot(aes(x = HANX)) + geom_histogram() + facet_grid(Time~GroupTier, scales="free")

data_df_anl_HANX %>% 
  ggplot(aes(x = Time, y = HANX, group = Participant_Number, colour = Participant_Number)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~GroupTier)

# describe numeric difference
data_df_anl_HANX %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(clinical = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(GroupTier) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqClinical = sum(clinical),
            percClinical = freqClinical/n(),
            freqRemission = sum(remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_HANX %>% aov(HANX ~ GroupTier*Time + Error(Participant_Number), data = .) %>% summary()

# single t tests
data_df_anl_HANX %>% filter(GroupTier == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HANX %>% filter(GroupTier == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HANX %>% filter(GroupTier == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

