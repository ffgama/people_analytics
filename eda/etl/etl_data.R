rm(list=ls())

library(data.table)

INPUT_FILE = "eda/data/dataset_people.csv"
OUTPUT_FILE = "eda/data/transf_people_data"

load_data = function(path_file, header="TRUE", separator=","){
  
  data = fread(path_file, sep=separator)

}

people_data = load_data(INPUT_FILE)

# Overview do dataset
head(people_data, 3)

# checando consistencia dos tipos de dados
str(people_data)

# todas as colunas estao preenchidas
sapply(people_data, function(x) sum(!complete.cases(x)))

people_data = people_data %>%
  mutate_at(vars(Education), ~case_when(
    .==1 ~ "Below College",
    .==2 ~ "College",
    .==3 ~ "Bachelor",
    .==4 ~ "Master",
    .==5 ~ "Doctor"
  )) %>%
  mutate_at(vars(EnvironmentSatisfaction), ~case_when(
    .==1 ~ "Low",
    .==2 ~ "Medium",
    .==3 ~ "High",
    .==4 ~ "Very High"
  )) %>%
  mutate_at(vars(JobInvolvement), ~case_when(
    .==1 ~ "Low",
    .==2 ~ "Medium",
    .==3 ~ "High",
    .==4 ~ "Very High"
  )) %>%
  mutate_at(vars(JobSatisfaction), ~case_when(
    .==1 ~ "Low",
    .==2 ~ "Medium",
    .==3 ~ "High",
    .==4 ~ "Very High"
  )) %>%
  mutate_at(vars(PerformanceRating), ~case_when(
    .==1 ~ "Low",
    .==2 ~ "Good",
    .==3 ~ "Excellent",
    .==4 ~ "Outstanding"
  )) %>%
  mutate_at(vars(RelationshipSatisfaction), ~case_when(
    .==1 ~ "Low",
    .==2 ~ "Medium",
    .==3 ~ "High",
    .==4 ~ "Very High"
  )) %>%
  mutate_at(vars(WorkLifeBalance), ~case_when(
    .==1 ~ "Bad",
    .==2 ~ "Good",
    .==3 ~ "Better",
    .==4 ~ "Best"
  )) 


# CSV: leitura no Pyt
# .RData: leitura no R
write.csv(people_data, file = paste(OUTPUT_FILE, ".csv", sep=""), row.names = FALSE)
save(people_data, file = paste(OUTPUT_FILE, ".RData", sep=""))