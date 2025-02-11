library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv') #, na = c("\\N") to treat \\N as NA

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips)) 

# convert dates strings to dates
# trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))

## NOTE '7$' mean end with 7 in regex

########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
nrow(trips)

# find the earliest and latest birth years (see help for max and min to deal with NAs)
trips %>%
  filter(birth_year != '\\N')  %>%  # or filter(grepl("^(18|19|20)[0-9]{2}", birth_year))
  summarize(max_birthyear = max(birth_year), min_birthyear = min(birth_year))

# use filter and grepl to find all trips that either start or end on broadway
trips %>%
  filter(grepl("Broadway", start_station_name) | grepl("Broadway", end_station_name))

# do the same, but find all trips that both start and end on broadway
trips %>%
  filter(grepl("Broadway", start_station_name) & grepl("Broadway", end_station_name))

# find all unique station names
unique(c(trips$start_station_name, trips$end_station_name))

# count the number of trips by gender, the average trip time by gender, and the standard deviation in trip time by gender
# do this all at once, by using summarize() with multiple arguments
trips %>%
  group_by(gender) %>%
  summarize(trips = n(), mean_duration = mean(tripduration), sd_duration = sd(tripduration))

# find the 10 most frequent station-to-station trips
trips %>%
  count(start_station_name, end_station_name) %>%
  arrange(desc(n)) %>%
  head(10)
  
# find the top 3 end stations for trips starting from each start station
trips %>%
  group_by(start_station_name) %>%
  count(start_station_name, end_station_name) %>%
  arrange(start_station_name, desc(n)) %>%
  top_n(3)

# find the top 3 most common station-to-station trips by gender
trips %>%
  group_by(gender) %>%
  count(start_station_name, end_station_name) %>%
  arrange(gender, desc(n)) %>%
  top_n(3)

# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)
trips %>%
  mutate(date = as.Date(starttime)) %>%
  count(date) %>%
  arrange(n) %>%
  slice_tail()

# compute the average number of trips taken during each of the 24 hours of the day across the entire month
## average number of trips per hour for the month
## group by day
trips %>%
  mutate(hour = hour(starttime)) %>% # hour(trips$starttime) or hour = format(starttime, format = "%H")
  add_count(hour, name = "trips_by_hour") %>%
  summarize(mean_trips_per_hour = mean(trips_by_hour))
  
# what time(s) of day tend to be peak hour(s)?
trips %>%
  mutate(hour = hour(starttime)) %>%
  count(hour) %>%
  arrange(desc(n)) %>%
  head()

# bonus because I misunderstood the question on line 77
# below calculates the average number of trips per day for the month
trips %>%
  mutate(date = as.Date(starttime)) %>%
  add_count(date, name = "trips_by_day") %>%
  summarize(mean_trips_per_day = mean(trips_by_day))