import sys, datetime, json
from haversine import haversine
import numpy as np


# TODO: gather command line arguments, simulate for dev
subject_state = 'OK'
seed_num = 1300
num_clusters = 5
population_epsilon = 0.1



# Read in Raw Data
with open('./data/zip_pop.json', 'r') as f:
    raw_data = json.loads(f.read())

'''
[{  u'latitude': 42.0706,
    u'state': u'MA',
    u'longitude': -72.6203,
    u'zip': u'01001',
    u'population': 16769
}]
'''


# Build Global References
zip_pop = {}; zip_coords = {}; state_zips = {}
for i in raw_data:
    zip_pop[i['zip']] = i['population']
    zip_coords[i['zip']] = (i['latitude'], i['longitude'])
    if i['state'] not in state_zips:
        state_zips[i['state']] = []
    state_zips[i['state']].append(i['zip'])


#print zip_pop['73162']
#print zip_coords['73162']
#print state_zips['OK'][:10]


#print haversine(zip_coords['73162'], zip_coords['73106'], miles = True)






def init_assignment(): pass
def evolve_cluster(): pass
def make_switch_set(): pass
def make_move_set(): pass
def cluster_pop_balance(): pass
def score_cluster(cluster):
    collector = []
    for i in cluster:
        running_k = []
        # TODO: rewrite with combinatoric method
        for k_l in i:
            for k_r in i:
                if (int(k_l) >= int(k_r)):
                    continue  # only compare 1 way, not to itself
                running_k.append(haversine(zip_coords[k_l], zip_coords[k_r]))
        collector.append(np.mean(running_k))
    return np.mean(collector)




#------------------------------------------------
# Unit Tests
print '\n'
print 'Unit Test: score_cluster()'
start_time = datetime.datetime.now()
test_k = [['73002', '73003','73004'],['73005','73007','73008','73009']]
print score_cluster(test_k)
print 'Execution Time: ', datetime.datetime.now() - start_time
