library(jsonlite)
library(dplyr)



# Load ZIP, population, and config data types
zip <- tbl_df(read.csv(file = './data/zipcode.csv',
                       header = TRUE,
                       colClasses = 'character'))

pop <- read.csv(file = './data/pop_zip_2010.csv',
                header = TRUE,
                colClasses = 'character')

zip_pop <- zip %>%
    inner_join(y = pop, by = 'zip') %>%
    mutate(state = as.character(state)) %>%
    mutate(latitude = as.numeric(latitude)) %>%
    mutate(longitude = as.numeric(longitude)) %>%
    mutate(population = as.numeric(population)) %>%
    filter(population > 0) %>%
    select(zip, state, latitude, longitude, population)


zip_pop_json <- toJSON(zip_pop)
write(x = zip_pop_json, file = './data/zip_pop.json')