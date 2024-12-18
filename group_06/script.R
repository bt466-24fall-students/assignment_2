library(dplyr)
library(readr)
library(skimr)

# Define paths for downloading and reading data
raw_data <- "raw_data"
dataset_url <- "https://data.iowa.gov/api/views/qd3t-kfqg/rows.csv?accessType=DOWNLOAD"


# Define file path for dataset
dataset_path <- file.path(raw_data, "Iowa_Economic_Indicators.csv")

#Create raw_data folder if not already created
if (!dir.exists(raw_data)) {
  dir.create(raw_data)
}

# Check if dataset downloaded, if not download
if (!file.exists(dataset_path)) {
  download.file(dataset_url, dataset_path, mode = "wb")
}

# Read the CSV file
Iowa_Economic_Indicators <- read_csv(dataset_path)

# Make sure data is only object in environment
#309 Rows 17 Columns
rm(list = setdiff(ls(),"Iowa_Economic_Indicators"))

print(head(Iowa_Economic_Indicators,5))

print(tail(Iowa_Economic_Indicators,5))

#Wide array of units, all but date are numeric and most are indexes

glimpse(Iowa_Economic_Indicators)

#NA for diffusion indexes is because they need due to the need of prior data
#Profits doesn't specify unit (billions, millions, etc)

skim(Iowa_Economic_Indicators)

#Diesel Fuel Consumption has a large standard deviation, is only column with 8 digits
#Non-Farm Employment Coincident Index stays similar throughout data set
#Agricultural Futures Profits Index has a negative mean

Iowa_Economic_Indicators <- Iowa_Economic_Indicators %>%
  rename(
    `Corn Profits (cents per bushel)`=`Corn Profits`,
    `Soybean Profits (cents per bushel)`=`Soybean Profits`,
    `Cattle Profits (cents per pound)`=`Cattle Profits`,
    `Hog Profits (cents per pound)`=`Hog Profits`
  )

#Make sure changes went through
skim(Iowa_Economic_Indicators)

#Select key columns
key_columns<-Iowa_Economic_Indicators %>%
  select(
    Month,
    `Iowa Leading Indicator Index`,
    `Avg Weekly Manufacturing Hours`,
    `Residential Building Permits`,
    `Avg Weekly Unemployment Claims`,
    `Yield Spread`,
    `Diesel Fuel Consumption (Gallons)`,
    `Iowa Stock Market Index`,
    `Agricultural Futures Profits Index`,
    `Corn Profits (cents per bushel)`,
    `Soybean Profits (cents per bushel)`,
    `Cattle Profits (cents per pound)`,
    `Hog Profits (cents per pound)`
  )

#Ensure columns are selected    
print(key_columns)

#Created a new column, Average_Profits, which is the average of the four profit columns
key_columns<-key_columns %>%
  mutate(
    Average_Profits=rowMeans(select(.,`Corn Profits (cents per bushel)`, 
                                      `Soybean Profits (cents per bushel)`, 
                                      `Cattle Profits (cents per pound)`, 
                                      `Hog Profits (cents per pound)`), 
    )
  )

#Ensure new row was created
print(key_columns$Average_Profits)

#Filter for missing data
missing_data<-key_columns %>%
  filter(if_any(everything(),is.na))

#Print missing values
print(missing_data)

#Save copy of key_columns
save<-file.path("raw_data","Revised_Iowa_Economic_Indicators.csv")
write.csv(key_columns,save)
cat("Copy was saved at",save)

#I added units to the agricultural profits so that they could be better understood.
#I selected 12 key columns based on their usefulness, the rest were excluded because they either weren't useful or weren't easily understood.
#I created a new column, Average_Profits, which is the average of the four profit columns. My intent was to create a column which better reflected how industry profits were changing.
#I filtered out missing data but no action was needed as there were none.
