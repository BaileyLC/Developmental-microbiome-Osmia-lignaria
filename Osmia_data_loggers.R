### Project: Osmia climate change

## Purpose - Aggregate temp. data from loggers (LBC 2022-2023) to create a daily temp. protocol for Osmia Climate Change project

# Helpful resource: https://stackoverflow.com/questions/24645628/how-to-calculate-average-of-a-variable-by-hour-in-r

# Set working directory
  setwd("~/Downloads")

# Load necessary packages
  library(tidyverse) 
  library(lubridate)
  library(dplyr)
  library(readr)
  library(xts)
  
# Import data
  all_loggers <- list.files(path = "Research/Osmia/data_logger", full.names = TRUE) %>% 
    lapply(read_csv) %>% 
    bind_rows

# Rename column headers
  colnames(all_loggers) <- c("Date", "Hour", "Unit", "Temp")

# Format into a xts and add column combining Date and Hour
  all_loggers.xts <- xts(all_loggers$Temp, as.POSIXct(paste(all_loggers$Date, all_loggers$Hour), format="%m/%d/%Y %H:%M:%S"))
    
# Check to see if it worked
  head(all_loggers.xts)

# Get the means for each hour
  means <- period.apply(all_loggers.xts, endpoints(all_loggers.xts, "hours"), mean)
  
# Check to see if it worked  
  head(means)
  
# Align time stamps to the beginning of the hour
  align.time.down = function(x,n){index(x) = index(x)-n; align.time(x,n)}
  means.rounded <- align.time.down(means, 60*60)
  
# Check to see if it worked
  head(means.rounded)

# Plot data
  plot(means.rounded, las = 1, main = "Hourly Avg Temperatures")
  
# Save data
  write.csv(means, "Research/Osmia/mean_all_loggers.csv", row.names = FALSE)
  
# Extract date and time; save data
  date_time <- index(means)
  write.csv(date_time, "Research/Osmia/date_times.csv", row.names = FALSE)

#######################
  
# Add a column 
  all_loggers$Week <- strftime(all_loggers$Date, format = "%V")
    