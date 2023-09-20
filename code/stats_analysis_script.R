# Set-up script for open label MDD TMS analysis

setwd("L:/Lab_JamesR/lachlanW/QNC_MDD_analysis/QNC_outcomes")

library(readxl)
library(dplyr)
library(magrittr)
library(tidyr)
library(ggplot2)

# setting up code to run on random sample, after final data collection, can remove slice_sample
sample_df <- read_excel("data/220901 Anonymised QNC Clinical Data (Inc. Coordinates)_UPDATED_04092023.xlsx", sheet = 1, n_max = 69) #%>% slice_sample(n = 10)
## ## ## double check nmax when reading in

data_df <- sample_df

## Make factor labels ####

data_df <- data_df %>%
  mutate(Research_Tier = factor(`Research Tier`,
                            levels = c(1,2,3),
                            labels = c("RCT Acceptable", "Naturalistic Population", "Bipolar or Neurological Disorder")),
         Gender = factor(Gender,
                         levels = c(1,2),
                         labels = c("Female","Male")),
         Handedness = factor(Handedness,
                             levels = c(1,2),
                             labels = c("Right","Left")),
         Prim_Diag = factor(`Primary Diagnosis`,
                           levels = c(1,2),
                           labels = c("Treatment MDD", "Bipolar")),
         Prim_MDD = factor(`Primary MDD`,
                          levels = c(1,2,3),
                          labels = c("Yes", "Secondary", "Bipolar Depression")),
         Referrer = factor(Referrer,
                           levels = c(1,2),
                           labels = c("GP", "Psychiatrist")),
         Prev_TMS = factor(`Previous TMS`,
                          levels = c(0,1),
                          labels = c("No","Yes")),
         Prev_ECT = factor(`Previous ECT`,
                          levels = c(0,1),
                          labels = c("No","Yes"))
  )

### missing values ####

data_df$`Years_of_Education (years)`[data_df$`Years_of_Education (years)` == 99] <- NA


# groups ####

table(data_df$Research_Tier)

data_df %$% table(Research_Tier,Prim_MDD) 

data_df %>% filter(Research_Tier == "Naturalistic Population" & Prim_MDD == "Bipolar Depression") %>% select(Participant_Number)

## Descriptive statistics of demographics ####

# need to clarify what the tier system is

data_df %<>% mutate(Age = as.numeric(Age))

data_df %>% summarise(
  mean_age = mean(Age, na.rm = TRUE),
  sd_age = sd(Age, na.rm = TRUE),
  median_age = median(Age, na.rm = TRUE),
  Q1_age = quantile(Age,0.25, na.rm = TRUE),
  Q3_age = quantile(Age,0.75, na.rm = TRUE),
  mean_edu = mean(`Years_of_Education (years)`, na.rm = TRUE),
  sd_edu = sd(`Years_of_Education (years)`, na.rm = TRUE),
  median_edu = median(`Years_of_Education (years)`, na.rm = TRUE),
  Q1_edu = quantile(`Years_of_Education (years)`,0.25, na.rm = TRUE),
  Q3_edu = quantile(`Years_of_Education (years)`,0.75, na.rm = TRUE),
  mean_diag = mean(`Age_of_Diagnosis (years)`, na.rm = TRUE),
  sd_diag = sd(`Age_of_Diagnosis (years)`, na.rm = TRUE),
  median_diag = median(`Age_of_Diagnosis (years)`, na.rm = TRUE),
  Q1_diag = quantile(`Age_of_Diagnosis (years)`,0.25, na.rm = TRUE),
  Q3_diag = quantile(`Age_of_Diagnosis (years)`,0.75, na.rm = TRUE),
  mean_sympt = mean(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
  sd_sympt = sd(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
  median_sympt = median(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
  Q1_sympt = quantile(`Age_of_Symptom_Onset (years)`,0.25, na.rm = TRUE),
  Q3_sympt = quantile(`Age_of_Symptom_Onset (years)`,0.75, na.rm = TRUE)
)

# n
data_df %>% summarise(
  num_age = sum(!is.na(Age)),
  num_edu = sum(!is.na(`Years_of_Education (years)`)),
  num_diag = sum(!is.na(`Age_of_Diagnosis (years)`)),
  num_sympt = sum(!is.na(`Age_of_Symptom_Onset (years)`))
)




data_df %>% 
  group_by(Research_Tier) %>%
  summarise(
    mean_age = mean(Age, na.rm = TRUE),
    sd_age = sd(Age, na.rm = TRUE),
    median_age = median(Age, na.rm = TRUE),
    Q1_age = quantile(Age,0.25, na.rm = TRUE),
    Q3_age = quantile(Age,0.75, na.rm = TRUE),
    mean_edu = mean(`Years_of_Education (years)`, na.rm = TRUE),
    sd_edu = sd(`Years_of_Education (years)`, na.rm = TRUE),
    median_edu = median(`Years_of_Education (years)`, na.rm = TRUE),
    Q1_edu = quantile(`Years_of_Education (years)`,0.25, na.rm = TRUE),
    Q3_edu = quantile(`Years_of_Education (years)`,0.75, na.rm = TRUE),
    mean_diag = mean(`Age_of_Diagnosis (years)`, na.rm = TRUE),
    sd_diag = sd(`Age_of_Diagnosis (years)`, na.rm = TRUE),
    median_diag = median(`Age_of_Diagnosis (years)`, na.rm = TRUE),
    Q1_diag = quantile(`Age_of_Diagnosis (years)`,0.25, na.rm = TRUE),
    Q3_diag = quantile(`Age_of_Diagnosis (years)`,0.75, na.rm = TRUE),
    mean_sympt = mean(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
    sd_sympt = sd(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
    median_sympt = median(`Age_of_Symptom_Onset (years)`, na.rm = TRUE),
    Q1_sympt = quantile(`Age_of_Symptom_Onset (years)`,0.25, na.rm = TRUE),
    Q3_sympt = quantile(`Age_of_Symptom_Onset (years)`,0.75, na.rm = TRUE)
    )

# n
data_df %>% 
  group_by(Research_Tier) %>%
  summarise(
    num_age = sum(!is.na(Age)),
    num_edu = sum(!is.na(`Years_of_Education (years)`)),
    num_diag = sum(!is.na(`Age_of_Diagnosis (years)`)),
    num_sympt = sum(!is.na(`Age_of_Symptom_Onset (years)`))
)

data_df %$% table(Gender)
data_df %$% table(Handedness)
data_df %$% table(Prim_Diag)
data_df %$% table(Prim_MDD)
data_df %$% table(Research_Tier)
data_df %$% table(Referrer)

data_df %$% table(Gender) %>% prop.table() * 100
data_df %$% table(Handedness) %>% prop.table() * 100
data_df %$% table(Prim_Diag) %>% prop.table() * 100
data_df %$% table(Prim_MDD) %>% prop.table() * 100
data_df %$% table(Research_Tier) %>% prop.table() * 100
data_df %$% table(Referrer) %>% prop.table() * 100


data_df %$% table(Gender,Research_Tier)
data_df %$% table(Handedness,Research_Tier)
data_df %$% table(Prim_Diag,Research_Tier)
data_df %$% table(Prim_MDD,Research_Tier)
data_df %$% table(Research_Tier,Research_Tier)
data_df %$% table(Referrer,Research_Tier)

data_df %$% table(Gender,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Handedness,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Prim_Diag,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Prim_MDD,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Research_Tier,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Referrer,Research_Tier) %>% prop.table(margin = 2) * 100


kruskal.test(data_df$Age, data_df$Research_Tier)
chisq.test(data_df$Gender, data_df$Research_Tier)
fisher.test(data_df$Gender, data_df$Research_Tier)

kruskal.test(data_df$`Age_of_Diagnosis (years)`, data_df$Research_Tier)
kruskal.test(data_df$`Age_of_Symptom_Onset (years)`, data_df$Research_Tier)


data_df %$% table(Prev_TMS)
data_df %$% table(Prev_ECT)

data_df %$% table(Prev_TMS) %>% prop.table() * 100
data_df %$% table(Prev_ECT) %>% prop.table() * 100

data_df %$% table(Prev_TMS,Research_Tier)
data_df %$% table(Prev_ECT,Research_Tier)

data_df %$% table(Prev_TMS,Research_Tier) %>% prop.table(margin = 2) * 100
data_df %$% table(Prev_ECT,Research_Tier) %>% prop.table(margin = 2) * 100

## will add checks for assumptions and conditions for analysis once final data is sorted

#### df for analysis ####

data_df_anl <- data_df %>%
  mutate(Group = Research_Tier)

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
  select(Participant_Number,Group,`PRE-MADRS_Total`,`POST-MADRS_Total`) %>%
  pivot_longer(c(`PRE-MADRS_Total`,`POST-MADRS_Total`), names_to = "Time_Measure", values_to = "MADRS") %>%
  mutate(Time = if_else(grepl("PRE",Time_Measure),1,
                        if_else(grepl("POST",Time_Measure),2,0))) %>%
  mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_MADRS %>% group_by(Group, Time) %>% summarise(meanMADRS = mean(MADRS),
                                                              sdMADRS = sd(MADRS),
                                                              minMADRS = min(MADRS),
                                                              maxMADRS = max(MADRS))
# plot
data_df_anl_MADRS %>% 
  ggplot(aes(x = MADRS)) + geom_histogram() + facet_grid(Group~Time, scales="free")

# describe numeric difference
data_df_anl_MADRS %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(Response = percdiff <= -50,
         Remission = Post <= 10) %>%
  group_by(Group) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqResponse = sum(Response),
            percResponse = freqResponse/n(),
            freqRemission = sum(Remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_MADRS %>% aov(MADRS ~ Group*Time + Error(Participant_Number), data = .) %>% summary()
data_df_anl_MADRS %>% aov(MADRS ~ Group*Time + Error(Participant_Number), data = .) %>% DescTools::EtaSq(type = 1, anova = TRUE)

# single t tests
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3

data_df_anl_MADRS %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3

data_df_anl_MADRS %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = MADRS) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3


data_df_anl_MADRS %>% filter(Group == GroupTierLevels[1]) %>% rstatix::cohens_d(MADRS ~ Time, paired = TRUE)
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[2]) %>% rstatix::cohens_d(MADRS ~ Time, paired = TRUE)
data_df_anl_MADRS %>% filter(Group == GroupTierLevels[3]) %>% rstatix::cohens_d(MADRS ~ Time, paired = TRUE)

#### HAMA ####

# analysis data set
data_df_anl_HAMA <- data_df_anl %>% 
  select(Participant_Number,Group,`PRE-HAMA_Total`,`POST-HAMA_Total`) %>%
  pivot_longer(c(`PRE-HAMA_Total`,`POST-HAMA_Total`), names_to = "Time_Measure", values_to = "HAMA") %>%
  mutate(Time = if_else(grepl("PRE",Time_Measure),1,
                        if_else(grepl("POST",Time_Measure),2,0))) %>%
  mutate(Time = factor(Time, levels = c(1,2), labels = c("Pre","Post")))

# describe time points in each group
data_df_anl_HAMA %>% group_by(Group, Time) %>% summarise(meanHAMA = mean(HAMA),
                                                             sdHAMA = sd(HAMA),
                                                             minHAMA = min(HAMA),
                                                             maxHAMA = max(HAMA))
# plot
data_df_anl_HAMA %>% 
  ggplot(aes(x = HAMA)) + geom_histogram() + facet_grid(Group~Time, scales="free")

# describe numeric difference
data_df_anl_HAMA %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(Response = percdiff <= -50,
         Remission = Post <= 7) %>%
  group_by(Group) %>%
  summarise(meanPercDiff = mean(percdiff),
            sdPercDiff = sd(percdiff),
            freqResponse = sum(Response),
            percResponse = freqResponse/n(),
            freqRemission = sum(Remission),
            percRemission = freqRemission/n())

# overall anova
data_df_anl_HAMA %>% aov(HAMA ~ Group*Time + Error(Participant_Number), data = .) %>% summary()
data_df_anl_HAMA %>% aov(HAMA ~ Group*Time + Error(Participant_Number), data = .) %>% DescTools::EtaSq(type = 1, anova = TRUE)

# single t tests
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3

data_df_anl_HAMA %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3

data_df_anl_HAMA %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE)
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HAMA) %$% t.test(Pre,Post, paired = TRUE) %$% p.value*3

data_df_anl_HAMA %>% filter(Group == GroupTierLevels[1]) %>% rstatix::cohens_d(HAMA ~ Time, paired = TRUE)
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[2]) %>% rstatix::cohens_d(HAMA ~ Time, paired = TRUE)
data_df_anl_HAMA %>% filter(Group == GroupTierLevels[3]) %>% rstatix::cohens_d(HAMA ~ Time, paired = TRUE)

#### HADS Dep ####

# analysis data set
data_df_anl_HDEP <- data_df_anl %>% 
  select(Participant_Number,Group,`Dep_Total-PRE`,`Dep_Total-W1`,`Dep_Total-W2`,`Dep_Total-W3`,`Dep_Total-W4`,`Dep_Total-POST`) %>%
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
data_df_anl_HDEP %>% group_by(Group, Time) %>% summarise(meanHDEP = mean(HDEP, na.rm = TRUE),
                                                             sdHDEP = sd(HDEP, na.rm = TRUE),
                                                             minHDEP = min(HDEP, na.rm = TRUE),
                                                             maxHDEP = max(HDEP, na.rm = TRUE),
                                                         num = sum(!is.na(HDEP)))
# plot
data_df_anl_HDEP %>% 
  ggplot(aes(x = HDEP)) + geom_histogram() + facet_grid(Group~Time, scales="free")
data_df_anl_HDEP %>% 
  ggplot(aes(x = HDEP)) + geom_histogram() + facet_grid(Time~Group, scales="free")

data_df_anl_HDEP %>% 
  ggplot(aes(x = Time, y = HDEP, group = Participant_Number, colour = Participant_Number)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~Group)

# describe numeric difference
data_df_anl_HDEP %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(Response = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(Group) %>%
  summarise(meanPercDiff = mean(percdiff, na.rm = TRUE),
            sdPercDiff = sd(percdiff, na.rm = TRUE),
            freqResponse = sum(Response, na.rm = TRUE),
            percResponse = freqResponse/n(),
            freqRemission = sum(remission, na.rm = TRUE),
            percRemission = freqRemission/n(),
            num = sum(!is.na(percdiff)))

# overall anova
data_df_anl_HDEP %>% aov(HDEP ~ Group*Time + Error(Participant_Number), data = .) %>% summary() # unbalanced

data_df_anl_HDEP %>% 
  filter(!is.na(HDEP)) %>% 
  group_by(Participant_Number) %>% 
  mutate(num = n()) %>% 
  filter(num == 6) %>% 
  ungroup() %>%
  aov(HDEP ~ Group*Time + Error(Participant_Number), data = .) %>% summary() # balanced

data_df_anl_HDEP %>% 
  filter(!is.na(HDEP)) %>% 
  group_by(Participant_Number) %>% 
  mutate(num = n()) %>% 
  filter(num == 6) %>% 
  ungroup() %>%
  aov(HDEP ~ Group*Time + Error(Participant_Number), data = .) %>% DescTools::EtaSq(type = 1, anova = TRUE) # balanced

library(lmerTest)
lmer_HADSDEP <- data_df_anl_HDEP %>% 
  filter(!is.na(HDEP)) %>% 
  #group_by(Participant_Number) %>% 
  #mutate(num = n()) %>% 
  #filter(num == 6) %>% 
  #ungroup() %>%
  filter(!(Time %in% c("Pre","Post"))) %>%
  mutate(Time_num = as.numeric(gsub("W","",Time))) %>%
  lmer(HDEP ~ Group*Time_num + (1|Participant_Number), data = .) #%>% summary() 
summary(lmer_HADSDEP)
confint(lmer_HADSDEP)



# single t tests
data_df_anl_HDEP %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HDEP %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HDEP %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HDEP) %$% t.test(Pre,Post, paired = TRUE)

#### HADS Anx ####

# analysis data set
data_df_anl_HANX <- data_df_anl %>% 
  select(Participant_Number,Group,`Anx_total-PRE`,`Anx_total-W1`,`Anx_total-W2`,`Anx_total-W3`,`Anx_total-W4`,`Anx_total-POST`) %>%
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
data_df_anl_HANX %>% group_by(Group, Time) %>% summarise(meanHANX = mean(HANX, na.rm = TRUE),
                                                             sdHANX = sd(HANX, na.rm = TRUE),
                                                             minHANX = min(HANX, na.rm = TRUE),
                                                             maxHANX = max(HANX, na.rm = TRUE),
                                                         num = sum(!is.na(HANX)))
# plot
data_df_anl_HANX %>% 
  ggplot(aes(x = HANX)) + geom_histogram() + facet_grid(Group~Time, scales="free")
data_df_anl_HANX %>% 
  ggplot(aes(x = HANX)) + geom_histogram() + facet_grid(Time~Group, scales="free")

data_df_anl_HANX %>% 
  ggplot(aes(x = Time, y = HANX, group = Participant_Number, colour = Participant_Number)) + 
  geom_line(show.legend = FALSE) + facet_wrap(~Group)

# describe numeric difference
data_df_anl_HANX %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %>%
  mutate(diff = Post - Pre) %>% 
  mutate(percdiff = diff/Pre*100) %>%
  mutate(Response = percdiff <= -50,
         remission = percdiff <= -80) %>%
  group_by(Group) %>%
  summarise(meanPercDiff = mean(percdiff, na.rm = TRUE),
            sdPercDiff = sd(percdiff, na.rm = TRUE),
            freqResponse = sum(Response, na.rm = TRUE),
            percResponse = freqResponse/n(),
            freqRemission = sum(remission, na.rm = TRUE),
            percRemission = freqRemission/n(),
            num = sum(!is.na(percdiff)))

# overall anova
data_df_anl_HANX %>% aov(HANX ~ Group*Time + Error(Participant_Number), data = .) %>% summary() # unbalanced

data_df_anl_HANX %>% 
  filter(!is.na(HANX)) %>% 
  group_by(Participant_Number) %>% 
  mutate(num = n()) %>% 
  filter(num == 6) %>% 
  ungroup() %>%
  aov(HANX ~ Group*Time + Error(Participant_Number), data = .) %>% summary() # balanced

data_df_anl_HANX %>% 
  filter(!is.na(HANX)) %>% 
  group_by(Participant_Number) %>% 
  mutate(num = n()) %>% 
  filter(num == 6) %>% 
  ungroup() %>%
  aov(HANX ~ Group*Time + Error(Participant_Number), data = .) %>% DescTools::EtaSq(type = 1, anova = TRUE) # balanced

library(lmerTest)
lmer_HADSANX <- data_df_anl_HANX %>% 
  filter(!is.na(HANX)) %>% 
  #group_by(Participant_Number) %>% 
  #mutate(num = n()) %>% 
  #filter(num == 6) %>% 
  #ungroup() %>%
  filter(!(Time %in% c("Pre","Post"))) %>%
  mutate(Time_num = as.numeric(gsub("W","",Time))) %>%
  lmer(HANX ~ Group*Time_num + (1|Participant_Number), data = .) #%>% summary() 
summary(lmer_HADSANX)
confint(lmer_HADSANX)


# single t tests
data_df_anl_HANX %>% filter(Group == GroupTierLevels[1]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HANX %>% filter(Group == GroupTierLevels[2]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

data_df_anl_HANX %>% filter(Group == GroupTierLevels[3]) %>% select(-`Time_Measure`) %>%
  pivot_wider(names_from = Time, values_from = HANX) %$% t.test(Pre,Post, paired = TRUE)

