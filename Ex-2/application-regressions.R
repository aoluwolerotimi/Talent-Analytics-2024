# EX 2 

# install.packages("arrow")
library(arrow)

data_path <- "/Users/aoluwolerotimi/Datasets/"
applications <- read_feather(paste0(data_path,"app_data_starter.feather"))

View(applications)
