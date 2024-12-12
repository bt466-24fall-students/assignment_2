#A1
# Path to Git Bash on your computer
git_bash_path <- "/bin/bash"
# Define the Kaggle dataset URL and file paths
kaggle_url <- "https://www.kaggle.com/api/v1/datasets/download/taseermehboob9/salary-dataset-of-business-levels"
output_dir <- "./raw_data"
zip_file <- file.path(output_dir, "archive.zip")

#Create folder "raw_data" if not exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# CURL command for downloading the dataset
curl_command <- sprintf("curl -L -o %s %s", shQuote(zip_file), shQuote(kaggle_url))

# Run the CURL command
system(paste(shQuote(git_bash_path), "-c", shQuote(curl_command)), intern = TRUE)

# Unzip command
unzip_command <- sprintf("unzip -o %s -d %s", shQuote(zip_file), shQuote(output_dir))

# Run the Unzip command
system(paste(shQuote(git_bash_path), "-c", shQuote(unzip_command)), intern = TRUE)

# Load the dataset
# Install required library
library(readr)

# Define a path to the csv file
salary_csv <- file.path(output_dir, "salary.csv")

# Reads the data from the salary_csv file into the R environment as a data frame
salary_df <- read_csv(salary_csv)

# Display first few rows of the dataframe
print(head(salary_df))


#A2

#LOAD & INPSECT
# Load necessary libraries
library(dplyr)  # For data manipulation
library(skimr)  # For detailed summary

# Glimpse the dataset to see structure and data types
glimpse(salary_df)

# View the first few rows of the dataset
head(salary_df)

# View the last few rows of the dataset
tail(salary_df)

# Use skimr to provide a detailed overview of the dataset
skim(salary_df)

#Comments on the dataset
print("Observations:
The dataset has 10 rows and 3 columns: Position (characters), Level (numeric) and Salary (numeric). 
Some examples of the Positions, as revealed by head() and tail(), are Business Analyst, Junior Consultant, Manager, etc. The rows are organized in the order of increasing position level, with the lowest level is Business Analyst and highest level position is CEO.
There are no missing values detected.
")

#CLEANING
# Step 1: Rename Columns
# Standardize column names: make them lowercase, replace spaces with underscores, and remove special characters
salary_df <- salary_df %>% 
  rename_all(~ gsub("[[:space:]]+", "_", .) %>% 
               gsub("[^[:alnum:]_]", "", .) %>% 
               tolower())

# Step 3: Create New Columns
# Add a column for the percentage increase in salary from one level below
salary_df <- salary_df %>% 
  arrange(level) %>% 
  mutate(salary_increase_percent = case_when(
    !is.na(lag(level)) & level != lag(level) ~ (salary - lag(salary)) / lag(salary) * 100, .default = 0
  ))

# Step 4: Handle Missing Data
# Check for missing values
missing_counts <- salary_df %>% 
  summarise_all(~ sum(is.na(.)))
print(missing_counts)

#To-do: Add a function to remove any row with NaN values


#Step 6: Save df as a new copy
write.csv(salary_df, "./raw_data/salary_cleaned.csv")

#Key Decisions: 
#We did not remove any columns since they are all important
#Renamed the columns into standardized names
#Created a column of % increase of salary from the level below to see how salaries change when moving up the level scale.
#Included functions to identify and remove rows with NaN values, however, this df did not have any NaN values.



