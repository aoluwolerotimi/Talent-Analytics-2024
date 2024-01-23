# EX 2 

## LOADING DATA

library(arrow)
library(tidyverse)
library(lubridate)


data_path <- "/Users/aoluwolerotimi/Datasets/"
# applications <- read_feather(paste0(data_path,"app_data_starter.feather"))
# 
# View(applications)

## INDIVIDUAL LEVEL VARIABLES: GENDER ## 
library(gender)
# library(devtools)

# install_genderdata_package() didn't work 
# install.packages("remotes")
library(remotes)
# options(timeout=400)


# get a list of first names without repetitions
# examiner_names <- applications %>% 
#   distinct(examiner_name_first)
# 
# examiner_names

# get a table of names and gender
# examiner_names_gender <- examiner_names %>% 
#   do(results = gender(.$examiner_name_first, method = "ssa")) %>% 
#   unnest(cols = c(results), keep_empty = TRUE) %>% 
#   select(
#     examiner_name_first = name,
#     gender,
#     proportion_female
#   )
# 
# examiner_names_gender

# remove extra colums from the gender table
# examiner_names_gender <- examiner_names_gender %>% 
#   select(examiner_name_first, gender)
# 
# View(examiner_names_gender)

# joining gender back to the dataset
# applications <- applications %>% 
#   left_join(examiner_names_gender, by = "examiner_name_first")

# cleaning up
# rm(examiner_names)
# rm(examiner_names_gender)
# gc()



## INDIVIDUAL LEVEL VARIABLES: RACE ## 

library(wru)

# examiner_surnames <- applications %>% 
#   select(surname = examiner_name_last) %>% 
#   distinct()
# 
# examiner_surnames
# 
# examiner_race <- predict_race(voter.file = examiner_surnames, surname.only = T) %>% 
#   as_tibble()

# examiner_race
# 
# examiner_race <- examiner_race %>% 
#   mutate(max_race_p = pmax(pred.asi, pred.bla, pred.his, pred.oth, pred.whi)) %>% 
#   mutate(race = case_when(
#     max_race_p == pred.asi ~ "Asian",
#     max_race_p == pred.bla ~ "black",
#     max_race_p == pred.his ~ "Hispanic",
#     max_race_p == pred.oth ~ "other",
#     max_race_p == pred.whi ~ "white",
#     TRUE ~ NA_character_
#   ))
# 
# examiner_race
# 
# examiner_race <- examiner_race %>% 
#   select(surname,race)

# applications <- applications %>% 
#   left_join(examiner_race, by = c("examiner_name_last" = "surname"))
# 
# rm(examiner_race)
# rm(examiner_surnames)
# gc()


## INDIVIDUAL LEVEL VARIABLES: TENURE ## 

# examiner_dates <- applications %>% 
#   select(examiner_id, filing_date, appl_status_date) 
# 
# examiner_dates
# 
# examiner_dates <- examiner_dates %>% 
#   mutate(start_date = ymd(filing_date), end_date = as_date(dmy_hms(appl_status_date)))
# 
# 
# examiner_dates <- examiner_dates %>% 
#   group_by(examiner_id) %>% 
#   summarise(
#     earliest_date = min(start_date, na.rm = TRUE), 
#     latest_date = max(end_date, na.rm = TRUE),
#     tenure_days = interval(earliest_date, latest_date) %/% days(1)
#   ) %>% 
#   filter(year(latest_date)<2018)
# 
# examiner_dates
# 
# applications <- applications %>% 
#   left_join(examiner_dates, by = "examiner_id")
# 
# rm(examiner_dates)
# gc()

# SAVING RESULTS FOR FUTURE ACCESS
# write_feather(applications, paste0(data_path,"app_data_starter_coded.feather"))


### CREATING PANEL DATASETS ###
applications_coded <- read_feather(paste0(data_path,"app_data_starter_coded.feather"))
View(applications_coded)

colnames(applications_coded)

library(dplyr)
library(zoo)

# ATTEMPT 1 - NOT WORKING
# applications_coded$earliest_quarter <- paste0(year(ymd(applications_coded$earliest_date.x)), "-", quarter(ymd(applications_coded$earliest_date.x)))
# applications_coded$latest_quarter <- paste0(year(ymd(applications_coded$latest_date.x)), "-", quarter(ymd(applications_coded$latest_date.x)))

# Create a new dataframe to store panel data
# panel_data <- data.frame()
# 
# View(examiner_data)
# sapply(examiner_data, class)


# partially executed loop
# # Loop over each examiner
# for(examiner_id in unique(applications_coded$examiner_id)) {
#   examiner_data <- applications_coded[applications_coded$examiner_id == examiner_id, ]
#   start_quarter <- examiner_data$earliest_quarter
#   end_quarter <- examiner_data$latest_quarter
#   
#   # Create sequence of quarters
#   quarters <- seq(from = as.yearqtr(start_quarter), to = as.yearqtr(end_quarter), by = "quarter")
# }

# cleaning up from that attempt
# rm(panel_data)
# rm(examiner_data)
# 
# applications_coded = subset(applications_coded, select = -c(earliest_quarter,latest_quarter))

# ATTEMPT 2 - ALSO NOT WORKING
# Function to generate sequence of quarters
# generate_quarters <- function(start_date, end_date) {
#   seq(from = ceiling_date(start_date, "quarter"), 
#       to = floor_date(end_date, "quarter"), 
#       by = "quarter")
# }
# 
# # Apply the function to each row
# quarterly_data <- applications_coded %>%
#   rowwise() %>%
#   mutate(quarters = list(generate_quarters(earliest_date.x, latest_date.x))) %>%
#   unnest(quarters)
# 
# # Create the panel dataset - HERE IS WHERE IT ERRORED OUT
# panel_dataset <- quarterly_data %>%
#   select(examiner_id, quarters) %>%
#   rename(quarter = quarters)
# 
# # Ensure the quarter has Date class
# panel_dataset$quarter <- as.Date(panel_dataset$quarter)
# 
# # View the panel dataset
# head(panel_dataset)


## ATTEMPT 3

firstDayOfQuarter <- function(date) {
  year <- year(date)
  quarter <- quarter(date)
  first_day <- ymd(paste(year, "-", (quarter - 1) * 3 + 1, "-01", sep=""))
  return(first_day)
}

applications_coded$quarter_start_date <- sapply(applications_coded$filing_date, firstDayOfQuarter)
## taking forever to run
