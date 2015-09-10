# Score Average Point distance per cluster, for all pairs
sub_zip <- zip %>% filter(state == 'OK') %>% select(zip, longitude, latitude)
sub_zip$cluster_id <- c(1:5)
score_cluster(sub_zip)

sub_zip <- zip %>% filter(state == 'OK') %>% select(zip, longitude, latitude)
sub_zip$cluster_id <- c(1:3)
score_cluster(sub_zip)


# Perform Cluster of Subject State DF
test_state <- zip %>% filter(state == 'OK') %>% sample_n(100)
test_seed <- sample(x = test_state$zip, size = 5)
clustered_state <- cluster_districts(sub_state = test_state,
                                     sub_seed = test_seed,
                                     pop_sensitivity = 0.1)
score_cluster(clustered_state)
nrow(clustered_state[is.na(clustered_state$cluster_id),])


# Helper: position based round robin matrix
test_state <- zip %>% filter(state == 'OK') %>% sample_n(8)
test_seed <- sample(x = test_state$zip, size = 3)
rr_one <- round_robin_matrix(sub_seed = test_seed, zip_sphere = test_state$zip, sub_position = 3)
dim(rr_one)
rr_all <- round_robin_full(sub_seed = test_seed, zip_sphere = test_state$zip)
dim(rr_all)


# Round Robin iterative improvement Function
test_state <- zip %>% filter(state == 'OK') %>% sample_n(25)
test_seed <- sample(x = test_state$zip, size = 5)
score_cluster(cluster_districts(sub_state = test_state, sub_seed = test_seed, pop_sensitivity = 0.1))

new_seed <- find_best_seed(sub_state = test_state, sub_seed = test_seed, pop_sensitivity = 0.1)
score_cluster(cluster_districts(sub_state = test_state, sub_seed = new_seed, pop_sensitivity = 0.1))

new_seed2 <- find_best_seed(sub_state = test_state, sub_seed = new_seed, pop_sensitivity = 0.1)
score_cluster(cluster_districts(sub_state = test_state, sub_seed = new_seed2, pop_sensitivity = 0.1))
system.time(score_cluster(cluster_districts(sub_state = test_state, sub_seed = new_seed2, pop_sensitivity = 0.1)))