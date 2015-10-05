library(jsonlite)
library(ggplot2)
library(dplyr)



cluster <- fromJSON(txt = './evolve_output/UT_k4_e5_s1300.json')
state_trans <- data_frame(code = state.abb, name = tolower(state.name))
sub_state <- subset(x = state_trans, subset = (code == cluster$state))


map <- map_data('state')
map_sub <- map[map$region == sub_state$name,]
ggplot(data = cluster$assignment, aes(x = longitude, y = latitude, color = as.factor(cluster_id))) +
    geom_map(aes(map_id = sub_state$name),
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

















