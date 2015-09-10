library(plyr)
library(dplyr)



# Load ZIP and config data types
zip <- read.csv(file = './data/zipcode.csv',
                header = TRUE,
                colClasses = 'character')

zip$state <- as.factor(zip$state)
zip$latitude <- as.numeric(zip$latitude)
zip$longitude <- as.numeric(zip$longitude)
zip <- zip[ ,1:5]

# Simulate Population Data
set.seed(1300)
zip$population <- rnorm(n = nrow(zip),
                        mean = 10000,
                        sd = 1500)


# Table by State
remove_states <- c('AS', 'DC', 'PR', 'VI')
agg_state <- zip %>%
    filter(!(state %in% remove_states)) %>%
    group_by(state) %>%
    summarize(
        records = n(),
        cities = n_distinct(city)) %>%
    arrange(state)

states <- unique(agg_state$state)












# Round Robin iterative improvement Function [PARALLEL]
find_best_seed_parallel <- function(sub_state, sub_seed, pop_sensitivity) {
  rr_all <- round_robin_full(sub_seed = sub_seed, zip_sphere = sub_state$zip)
  # TODO: implement .parallel functionality to plyr functions
  l_frames <- alply(.data = rr_all, .margins = 1, .fun = cluster_districts,
                    sub_state = sub_state, pop_sensitivity = pop_sensitivity)
  cluster_scores <- as.vector(laply(.data = l_frames, .fun = score_cluster))
  # TODO: look into using foreach package directly
  # TODO: bug check, function not producing expected output
  index_winner <- which.min(cluster_scores)
  seed_winner <- as.vector(rr_all[index_winner,])
  return(seed_winner)
}

test_state <- zip %>% filter(state == 'OK') %>% sample_n(25)
test_seed <- sample(x = test_state$zip, size = 5)
score_cluster(cluster_districts(sub_state = test_state, sub_seed = test_seed, pop_sensitivity = 0.1))

new_seed <- find_best_seed_parallel(sub_state = test_state, sub_seed = test_seed, pop_sensitivity = 0.1)
score_cluster(cluster_districts(sub_state = test_state, sub_seed = new_seed, pop_sensitivity = 0.1))




# TODO: make a visualization script that reads from either a list object of DFs or a flat file
# TODO: make translation data between state codes (ZIP) and state names (map_data)
# TODO: make a function that writes multiple runs of the cluster with different seeds to DF files
# TODO: function that makes a derivative table of scores for each version for each state
# Notes: run a loop that makes n random intializations and keeps each DF for a given state
# States: consider looping through all states, and/or one at a time

















































