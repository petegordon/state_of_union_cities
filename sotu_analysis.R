
# load libraries


check_and_install_package <- function(package){
  if (!package %in% installed.packages()[, "Package"]) {
    install.packages(package, repos = "http://cran.us.r-project.org")
  }
}

check_and_install_package("dplyr")
check_and_install_package("ggplot2")
check_and_install_package("tidyr")

library(dplyr)
library(ggplot2)
library(tidyr)


# read sotu speech text files into a list of data frames

directory <- normalizePath("./1980_to_2023")
if (getwd() != directory) setwd(directory)
filelist <- list.files(pattern = ".*.txt")
datalist <- lapply(filelist, function(x) read.delim(x, header=FALSE))
datafr <- do.call("rbind", datalist)

setwd(normalizePath(".."))
# read city names into a data frame

cities <- read.csv("./sotu_analysis_city_names.csv")
v.cities <- cities$city[1:50]

# fix city names

v.cities <- ifelse(v.cities == "Louisville/Jefferson County", "Louisville", v.cities)
v.cities <- ifelse(v.cities == "Nashville-Davidson", "Nashville", v.cities)
v.cities <- ifelse(v.cities == "Washington", "Washington, D.C.", v.cities)

# check proportion of population covered by top 50 cities

pop <- sum(cities$population)

cities %>%
  arrange(rank) %>%
  filter(rank <= 50) %>%
  select(population) %>%
  summarize(pop_sum = sum(population)) %>%
  unlist() %>%
  unname() -> pop.covered

round(pop.covered / pop, 2)

# find city names in sotu text
# output city name and sotu speech year to txt file 

sink("output_mentions_out.csv")

cat(paste0("City", ",", "Year"))
cat("\n")

for(i in 1:length(datalist)){
  for(j in 1:nrow(datalist[[i]])){
    for(k in 1:length(v.cities)){
      city.is.present <- FALSE
      city.is.present <- grepl(v.cities[k], datalist[[i]][j, 1])
      if(city.is.present){
        cat(paste0(v.cities[k], ",", gsub(".txt", "", filelist[i])))
        cat("\n")
      }
    }
  }
}
sink()

# Determine which city names have been mentioned in consecutive years

df <- read.csv("output_mentions_out.csv")

# Sort the dataframe by City and Year
df <- df %>% arrange(City, Year)

# Ensure City to Year is unique
unique_data <- unique(df)

# Create a dataframe with added column "Consecutive"
df <- unique_data %>%
  group_by(City) %>%
  mutate(
    Consecutive = (lag(Year) + 1) %in% Year | (lead(Year) - 1) %in% Year
  ) %>%
  ungroup()

dash_years <- unique(df$Year[df$Year %% 10 != 0])

# Plot
plot <- ggplot(data = df, aes(x = Year, y = City, color = Consecutive)) +
    geom_point() +
    geom_vline(xintercept = dash_years, linetype="dashed", color = "gray") +
    scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
    labs(title = "City by Year",
            x = "Year",
            y = "City",
            color = "Is Consecutive") +
    scale_y_discrete(limits = rev(sort(unique(df$City))))

# Save the plot to a file
ggsave("output_my_plot_red.png", plot = plot)
