library(dplyr)
library(ggplot2)

# Create the data frame
data <- read.csv('output_mentions_out.csv')
# Create a data frame with all years between 1980 and 2023
all_years <- data.frame(Year = 1980:2023)

# Merge the all_years data frame with the provided data to include missing years
data_complete <- merge(all_years, data, all.x = TRUE)

# Replace missing values with NA
data_complete$City[is.na(data_complete$City)] <- "No City Mentioned"

# Calculate the number of city mentions each year
num_city_mentions <- data %>%
  group_by(Year) %>%
  summarise(num_mentions = n_distinct(City))

# Plot the number of city mentions over the years as a line graph
plot <- ggplot(num_city_mentions, aes(x = Year, y = num_mentions)) +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Year", y = "Number of City Mentions") +
  ggtitle("Number of City Mentions Over the Years")
plot(plot)

# Calculate the average number of cities mentioned each year
average_cities_mentioned <- data_complete %>%
  group_by(Year) %>%
  summarise(num_cities_mentioned = n_distinct(City)) %>%
  summarise(average_cities_mentioned = mean(num_cities_mentioned))

# Print the average number of cities mentioned each year
print(average_cities_mentioned)

#2.32 mentions per year.

