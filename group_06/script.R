library(dplyr)
library(readr)
library(skimr)

# Define paths for downloading and reading data
raw_data <- "raw_data"
dataset_url <- "https://data.iowa.gov/api/views/qd3t-kfqg/rows.csv?accessType=DOWNLOAD"


# Define file path for dataset
dataset_path <- file.path(raw_data, "Iowa_Economic_Indicators.csv")

# Check if dataset downloaded, if not download
if (!file.exists(dataset_path)) {
  download.file(dataset_url, dataset_path, mode = "wb")
}

# Read the CSV file
Iowa_Economic_Indicators <- read_csv(dataset_path)

# Make sure data is only object in environment
rm(list = setdiff(ls(), "Iowa_Economic_Indicators"))

print(head(Iowa_Economic_Indicators, 5))

print(tail(Iowa_Economic_Indicators, 5))

glimpse(Iowa_Economic_Indicators)

skim(Iowa_Economic_Indicators)
