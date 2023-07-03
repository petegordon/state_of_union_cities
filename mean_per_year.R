library(dplyr)

# Create the data frame
data <- read.csv('output_mentions_out.csv')
# Create a data frame with all years between 1980 and 2023
all_years <- data.frame(Year = 1980:2023)

# Merge the all_years data frame with the provided data to include missing years
data_complete <- merge(all_years, data, all.x = TRUE)

# Replace missing values with NA
data_complete$City[is.na(data_complete$City)] <- "No City Mentioned"

# Calculate the average number of cities mentioned each year
average_cities_mentioned <- data_complete %>%
  group_by(Year) %>%
  summarise(num_cities_mentioned = n_distinct(City)) %>%
  summarise(average_cities_mentioned = mean(num_cities_mentioned))

# Print the average number of cities mentioned each year
print(average_cities_mentioned)

#2.32 mentions per year.