library(dplyr)
library(ggplot2)
library(maps)



run_state_name <- 'arkansas'
run_state_code <- 'AR'
load(file = './state/AR_k4_all_alt.RData')

# Visualize Clusters - Text Numbers
map <- map_data('state')
map_sub <- map[map$region == run_state_name,]
ggplot(data = zip_clust, aes(x = longitude, y = latitude, color = as.factor(cluster_id))) +
  geom_map(aes(map_id = run_state_name),
           map = map_sub,
           fill = 'light grey',
           color = 'black',
           size = 1.25) +
  expand_limits(x = map_sub$long, y = map_sub$lat) +
  geom_text(aes(label = cluster_id, fontface = 'bold')) +
  scale_color_brewer(palette = 'Set1') +
  guides(color = FALSE) +
  theme_classic() +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank())
#ggsave(file = './plots/OK_k6_150.png', dpi = 500)


# Visualize Clusters - Color Points
map <- map_data('state')
map_sub <- map[map$region == run_state_name,]
ggplot(data = zip_clust, aes(x = longitude, y = latitude, color = as.factor(cluster_id))) +
    geom_map(aes(map_id = run_state_name),
             map = map_sub,
             fill = 'light grey',
             color = 'black',
             size = 1.25) +
    expand_limits(x = map_sub$long, y = map_sub$lat) +
    geom_point(shape = 20, size = 6, alpha = 0.75) +
    scale_color_brewer(palette = 'Set1') +
    guides(color = FALSE) +
    theme_classic() +
    theme(axis.text = element_blank(),
          axis.title = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank())
#ggsave(file = './plots/AR_k4_points_alt.png', dpi = 500)


# Visualize before
zip_clust %>%
    ggplot(data = ., aes(x = longitude, y = latitude)) +
    geom_map(aes(map_id = run_state_name),
             map = map_sub,
             fill = 'light grey',
             color = 'black',
             size = 1.00) +
    expand_limits(x = map_sub$long, y = map_sub$lat) +
    geom_point(shape = 20, size = 6, color = 'black', alpha = 0.5) +
    guides(color = FALSE) +
    theme_classic() +
    theme(axis.text = element_blank(),
          axis.title = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank())
#ggsave(file = './plots/AR_zipcodes.png', dpi = 500)


# TODO: given optimal cluster seeds, produce animation of clustering process






