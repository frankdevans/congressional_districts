library(plyr)
library(dplyr)
library(ggplot2)
library(maps)


# Functions
dist_earth <- function(lon1, lat1, lon2, lat2) {
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- lon1 * rad
  b1 <- lat2 * rad
  b2 <- lon2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378137
  d <- R * c
  return(d)
}
score_cluster <- function(cluster_df) {
  dist <- cluster_df %>%
    inner_join(y = cluster_df,
               by = c('cluster_id')) %>%
    filter((zip.x != zip.y) & (as.integer(zip.x) < as.integer(zip.y))) %>%
    mutate(distance = dist_earth(lon1 = longitude.x,
                                 lat1 = latitude.x,
                                 lon2 = longitude.y,
                                 lat2 = latitude.y)) %>%
    group_by(cluster_id) %>%
    summarise(avg_dist = mean(distance))
  output <- mean(dist$avg_dist)
  return(output)
}
cluster_districts <- function(sub_state, sub_seed, pop_sensitivity) {
  n_districts <- length(sub_seed)
  sub_state$seed <- FALSE
  sub_state$seed[sub_state$zip %in% sub_seed] <- TRUE
  clust_init <- data.frame(zip = sub_seed,
                           cluster_id = (1:n_districts),
                           stringsAsFactors = FALSE)
  sub_state <- sub_state %>% left_join(y = clust_init, by = c('zip' = 'zip'))

  # Initialize Population Epsilon
  total_pop <- sum(sub_state$population)
  district_pop <- (total_pop / n_districts)
  population_epsilon <- district_pop + (district_pop * (pop_sensitivity / 2))

  # Produce Cluster Queue
  unclustered <- sub_state %>%
    filter(!seed) %>%
    select(zip, latitude, longitude, population) %>%
    rename(zip_candidate = zip,
           lat_candidate = latitude,
           lon_candidate = longitude,
           pop_candidate = population) %>%
    mutate(link_anchor = 1)

  cluster_queue <- sub_state %>%
    filter(seed) %>%
    select(zip, latitude, longitude, cluster_id) %>%
    rename(zip_seed = zip,
           lat_seed = latitude,
           lon_seed = longitude) %>%
    mutate(link_anchor = 1) %>%
    inner_join(y = unclustered,
               by = c('link_anchor' = 'link_anchor')) %>%
    mutate(distance = dist_earth(lon1 = lon_seed,
                                 lat1 = lat_seed,
                                 lon2 = lon_candidate,
                                 lat2 = lat_candidate)) %>%
    select(zip_seed, cluster_id, zip_candidate, pop_candidate, distance) %>%
    arrange(distance)

  # Assign Clusters from Queue
  loop_index <- 1:nrow(cluster_queue)
  for (i in loop_index) {
    # Move to next queue entry if already clustered
    if (!is.na(sub_state$cluster_id[sub_state$zip == cluster_queue$zip_candidate[i]])) next

    # Check to see if this addition will push the population over epsilon
    seed_pop <- sum((filter(.data = sub_state, cluster_id == cluster_queue$cluster_id[i]))$population)
    cand_pop <- cluster_queue$pop_candidate[i]
    if ((seed_pop + cand_pop) > population_epsilon) next

    # Make Cluster Update to sub_state DF
    cand_zip <- cluster_queue$zip_candidate[i]
    cand_cid <- cluster_queue$cluster_id[i]
    sub_state$cluster_id[sub_state$zip == cand_zip] <- cand_cid

  }
  return(sub_state)
}
round_robin_matrix <- function(sub_seed, zip_sphere, sub_position) {
  sub_seed <- sub_seed[-(sub_position)]
  zip_sphere <- setdiff(zip_sphere, sub_seed)
  rr_matrix <- aaply(.data = zip_sphere, .margins = 1, .fun = c, sub_seed)
  return(rr_matrix)
}
round_robin_full <- function(sub_seed, zip_sphere) {
  # TODO: consider rewrite with dplyr::rbind_all and apply function
  seed_matrix <- sub_seed  # Safe to skip in rewrite
  for (i in (1:length(sub_seed))) {
    rr_sub_pos <- round_robin_matrix(sub_seed = sub_seed,
                                     zip_sphere = zip_sphere,
                                     sub_position = i)
    seed_matrix <- rbind(seed_matrix, rr_sub_pos)
  }
  return(seed_matrix)
}
find_best_seed <- function(sub_state, sub_seed, pop_sensitivity) {
  rr_all <- round_robin_full(sub_seed = sub_seed, zip_sphere = sub_state$zip)
  cluster_scores <- rep(NA, times = nrow(rr_all))
  for (i in (1:(nrow(rr_all)))) {
    cluster_scores[i] <- score_cluster(cluster_districts(sub_state = sub_state,
                                                         sub_seed = as.vector(rr_all[i,]),
                                                         pop_sensitivity = pop_sensitivity))
  }
  index_winner <- which.min(cluster_scores)
  seed_winner <- as.vector(rr_all[index_winner,])
  return(seed_winner)
}
find_best_cluster <- function(zip_df, sub_state_code, n_districts, n_iterations, pop_sensitivity, n_sample) {
  sub_state <- zip_df %>% filter(state == sub_state_code) %>% sample_n(n_sample)
  sub_seed <- sample(x = sub_state$zip, size = n_districts)

  # Init Current State
  curr_seed <- sub_seed
  curr_cluster <- cluster_districts(sub_state = sub_state,
                                    sub_seed = curr_seed,
                                    pop_sensitivity = pop_sensitivity)
  curr_score <- score_cluster(curr_cluster)
  print(curr_score)
  curr_itr <- 0

  # Loop Through up to N iterations looking for better state
  while (curr_itr < n_iterations) {
    new_seed <- find_best_seed(sub_state = sub_state,
                               sub_seed = curr_seed,
                               pop_sensitivity = pop_sensitivity)
    new_cluster <- cluster_districts(sub_state = sub_state,
                                     sub_seed = new_seed,
                                     pop_sensitivity = pop_sensitivity)
    new_score <- score_cluster(new_cluster)
    if (new_score >= curr_score) break  # Exit on convergence or backtracking
    curr_seed <- new_seed
    curr_cluster <- new_cluster
    curr_score <- new_score
    curr_itr <- curr_itr + 1
    print(curr_score)
  }

  final_cluster <- cluster_districts(sub_state = zip_df %>% filter(state == sub_state_code),
                                     sub_seed = curr_seed,
                                     pop_sensitivity = pop_sensitivity)
  return(final_cluster)
}



# Load ZIP, population, and config data types
zip <- tbl_df(read.csv(file = './data/zipcode.csv',
                       header = TRUE,
                       colClasses = 'character'))

pop <- read.csv(file = './data/pop_zip_2010.csv',
                header = TRUE,
                colClasses = 'character')

zip_pop <- zip %>%
    inner_join(y = pop, by = 'zip') %>%
    mutate(state = as.factor(state)) %>%
    mutate(latitude = as.numeric(latitude)) %>%
    mutate(longitude = as.numeric(longitude)) %>%
    mutate(population = as.numeric(population)) %>%
    filter(population > 0) %>%
    select(zip, city, state, latitude, longitude, population)




# Make Cluster DF
run_state_name <- 'oklahoma'
run_state_code <- 'OK'

time_start <- Sys.time()
zip_clust <- find_best_cluster(zip_df = zip_pop,
                               sub_state_code = run_state_code,
                               n_districts = 5,
                               n_iterations = 10,
                               pop_sensitivity = 0.1,
                               n_sample = 100)
score_cluster(zip_clust)
time_end <- Sys.time()
difftime(time_end, time_start)

save(x = zip_clust, file = './state/OK_k5_150.RData')
