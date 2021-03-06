library(tidyverse); library(lubridate)

# from http://clt-charlotte.opendata.arcgis.com/datasets/c458bca429b542bbb31130c23510628a_7 (pulled 4/23)
df <- read_csv("./data/Officer_Traffic_Stops.csv")

# examine the data
str(df)

# How many were stopped? This will be our dependent variable
df %>% 
  count(Result_of_Stop)

# What was the timeframe?
# replace "/" with "-"
df$Month_of_Stop <- gsub("/","-",df$Month_of_Stop)
# add in a day
df$Month_of_Stop <- paste0(df$Month_of_Stop,"-01")
# created a date field
df$Date <- lubridate::ymd(df$Month_of_Stop)

# let's write this so we don't need to redo these steps
df %>%
  mutate(Month = format(Date, format="%b"),
         Year = format(Date, format="%Y")) %>%
  select(-CreationDate, -Creator, -EditDate, -Editor, -Month_of_Stop, -ObjectID, -Date) %>%
  drop_na() %>%
  write_csv("./data/cleaned-stops.csv")

# first plot
df %>%
  count(Date) %>%
  ggplot(aes(x = Date, y = n)) +
  geom_line()

# pretty it
df %>%
  count(Date) %>%
  ggplot(aes(x = Date, y = n)) +
  geom_line() +
  ylim(0, 10000) +
  labs(x = "Month of Stop",
       y = "Number of Stops",
       title = "CMPD Traffic Stops by Month")

# pretty it
df %>%
  count(Date, CMPD_Division) %>%
  filter(!is.na(CMPD_Division)) %>%
  ggplot(aes(x = Date, y = n)) +
  geom_line() +
  scale_x_date(date_labels = "%b %y") +
  labs(x = "Month of Stop",
       y = "Number of Stops",
       title = "CMPD Traffic Stops by Month") +
  facet_wrap(.~CMPD_Division)

# Driver Information

# driver gender and race
df %>%
  count(Driver_Gender, Driver_Race) %>%
  ggplot(aes(x = Driver_Gender, y = n, fill = Driver_Race)) +
  geom_col()

# driver gender, race, and ethnicity
df %>%
  count(Driver_Gender, Driver_Race, Driver_Ethnicity) %>%
  ggplot(aes(x = Driver_Gender, y = n, fill = Driver_Race)) +
  geom_col() +
  facet_wrap(~Driver_Ethnicity)

# Age
ggplot(df, aes(x = Driver_Age)) +
  geom_histogram(bins = 25)

# or use a geom_freqpoly()
ggplot(df, aes(x = Driver_Age)) +
  geom_freqpoly() +
  labs(x = "Driver Age",
       y = "Number of Traffic Stops")

# age by ethnicity
ggplot(df, aes(x = Driver_Age, fill = Driver_Ethnicity)) +
  geom_density(alpha = 0.2, adjust = 2)
