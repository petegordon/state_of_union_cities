
# load libraries

library(dplyr)
library(ggplot2)

# read sotu speech text files into a list of data frames

setwd("~/Downloads/state_of_union")
filelist = list.files(pattern = ".*.txt")
datalist = lapply(filelist, function(x) read.delim(x, header=FALSE))
datafr = do.call("rbind", datalist)

# read city names into a data frame

cities <- read.csv("~/Downloads/sotu_top_1k_cities.csv")
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

sink("~/Desktop/mentions_out.csv")

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

df <- read.csv("~/Desktop/mentions_out.csv")

# plot

df %>%
  mutate(counter = 1) %>%
  group_by(Year, City) %>%
  summarize(counter = sum(counter)) %>%
  ungroup() %>%
  mutate(counter = ifelse(counter >= 1, 1, 0)) %>%
  ggplot() +
    aes(
      x = Year,
      y = counter
    ) +
  geom_bar(stat = "identity") +
  facet_wrap(City ~ .) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90),
    axis.text.y=element_blank(),
    axis.ticks.y=element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
