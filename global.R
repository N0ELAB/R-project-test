library(shiny)
library(shinydashboard)
library(dplyr)
library(DT)
library(readr)
library(plotly)
library(tidyr)
library(scales)

cwur_data <- read.csv("data/cwurData.csv") %>%
  filter(world_rank <= 100) %>%
  mutate(
    year = as.numeric(year),
    continent = case_when(
      country %in% c("USA", "Canada") ~ "North America",
      country %in% c("United Kingdom", "Germany", "France", "Netherlands",
                     "Switzerland", "Belgium", "Sweden", "Denmark", "Italy",
                     "Spain", "Norway", "Finland", "Ireland", "Austria") ~ "Europe",
      country %in% c("Japan", "China", "South Korea", "Singapore",
                     "Hong Kong", "Taiwan") ~ "Asia",
      country == "Australia" ~ "Oceania",
      TRUE ~ "Other"
    )
  )

years <- sort(unique(cwur_data$year))
continents <- sort(unique(cwur_data$continent))
metrics <- c("Overall Score" = "score",
             "Education Quality" = "quality_of_education",
             "Alumni Employment" = "alumni_employment",
             "Faculty Quality" = "quality_of_faculty",
             "Publications" = "publications",
             "Citations" = "citations")

continent_summary <- cwur_data %>%
  group_by(year, continent) %>%
  summarise(
    avg_score = mean(score, na.rm = TRUE),
    count = n(),
    .groups = 'drop'
  )

steps <- read_csv2("help.csv")
