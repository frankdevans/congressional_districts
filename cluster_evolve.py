import sys, datetime, random, json
from haversine import haversine
import numpy as np


# TODO: gather command line arguments, simulate for dev
subject_state = 'OK'
num_clusters = 5
population_epsilon = 0.1

random.seed(1300)


# Read in Raw Data
with open('./data/zip_pop.json', 'r') as f:
    raw_data = json.loads(f.read())


# Build Global References
zip_pop = {}; zip_coords = {}; state_zips = {}
for i in raw_data:
    zip_pop[i['zip']] = i['population']
    zip_coords[i['zip']] = (i['latitude'], i['longitude'])
    if i['state'] not in state_zips:
        state_zips[i['state']] = []
    state_zips[i['state']].append(i['zip'])


''' Schema Notes
zip_pop = {zip:pop}
zip_coords = {zip:(lat,lon)}
state_zips = {ST:[zip,zip]}
'''



def init_assignment(state, clusters):
    cluster_set = [[] for i in range(clusters)]

    zips = state_zips[state]
    random.shuffle(zips)

    # Deal ZIP codes like cards to lowest running population at each step
    for i in zips:
        pop_each = cluster_pop_sum(cluster_set)
        index_push = pop_each.index(np.min(pop_each))
        cluster_set[index_push].append(i)

    return cluster_set
def make_switch_set(cluster):
    #[(zip, zip)] or [((k,zip),(k,zip))] in random order
    pass
def make_move_set(cluster):
    #[(zip,k_from, k_to)]  in random order
    k = len(cluster)
    collector = []

    for i in cluster:
        index_from = cluster.index(i)
        for z in i:
            for n in range(k):
                if n != index_from:
                    collector.append((z, index_from, n))

    random.shuffle(collector)
    return collector
def cluster_pop_sum(cluster):
    # Sum population for each cluster
    sum_pop = []
    for i in cluster:
        running_k = 0
        for z in i:
            running_k += zip_pop[z]
        sum_pop.append(running_k)
    return sum_pop
def cluster_pop_balance(cluster, pop_eps):
    pop_by_cluster = cluster_pop_sum(cluster)
    # Determine if epsilon violations
    pop_mean = np.mean(pop_by_cluster)
    pass_high = (np.max(pop_by_cluster) - pop_mean) / pop_mean <= pop_eps
    pass_low = (pop_mean - np.min(pop_by_cluster)) / pop_mean <= pop_eps
    return (pass_high and pass_low)
def score_cluster(cluster):
    collector = []
    for i in cluster:
        running_k = []
        # TODO: rewrite with combinatoric method, takes nearly .2 sec on OK-5
        for k_l in i:
            for k_r in i:
                if (int(k_l) >= int(k_r)):
                    continue  # only compare 1 way, not to itself
                running_k.append(haversine(zip_coords[k_l], zip_coords[k_r]))
        collector.append(np.mean(running_k))
    return np.mean(collector)
def evolve_cluster(): pass



#------------------------------------------------

# Unit Tests

'''
print '\n'
print 'Unit Test: init_assignment()'
start_time = datetime.datetime.now()
initial_state = init_assignment('OK', 5)
print 'Cluster 2, first 5: ', initial_state[2][:5]
print 'Cluster 3, first 5: ', initial_state[3][:5]
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: score_cluster()'
start_time = datetime.datetime.now()
test_k = [['73002', '73003','73004'],['73005','73007','73008','73009']]
print score_cluster(test_k)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: cluster_pop_sum()'
start_time = datetime.datetime.now()
test_k = [['73002', '73003','73004'],['73005','73007','73008','73009']]
print cluster_pop_sum(test_k)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: cluster_pop_sum() empty'
start_time = datetime.datetime.now()
test_k = [[],[]]
print cluster_pop_sum(test_k)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: cluster_pop_balance()'
start_time = datetime.datetime.now()
test_k = [['73002', '73003','73004'],['73005','73007','73008','73009']]
print cluster_pop_balance(test_k, 0.1)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: init_assignment, cluster_pop_sum, cluster_pop_balance, score_cluster'
start_time = datetime.datetime.now()
initial_state = init_assignment('OK', 5)
print 'Sum: ', cluster_pop_sum(initial_state)
print 'Balance: ', cluster_pop_balance(initial_state, 0.1)
print 'Score: ', score_cluster(initial_state)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Component Test Tiem Step-Through'
start_time = datetime.datetime.now()
initial_state = init_assignment('OK', 5)
print 'Time init_assignment: ', datetime.datetime.now() - start_time
cluster_pop_sum(initial_state)
print 'Time cluster_pop_sum: ', datetime.datetime.now() - start_time
cluster_pop_balance(initial_state, 0.1)
print 'Time cluster_pop_balance: ', datetime.datetime.now() - start_time
score_cluster(initial_state)
print 'Time score_cluster: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: make_move_set() test data'
start_time = datetime.datetime.now()
test_k = [['73002', '73003','73004'],['73005','73007','73008','73009']]
print make_move_set(test_k)
print 'Execution Time: ', datetime.datetime.now() - start_time


print '\n'
print 'Unit Test: make_move_set() real data'
start_time = datetime.datetime.now()
initial_state = init_assignment('OK', 5)
ms = make_move_set(initial_state)
print len(ms)
print ms[:20]
print 'Execution Time: ', datetime.datetime.now() - start_time



# Tool Functions
def num_moves(n,k):
    avg_k = n / k
    moves = (avg_k * (k - 1)) * k
    switches = n * (k - 1) * avg_k
    return (moves, switches)

print 'OK: ', num_moves(len(state_zips['OK']),5)
print 'FL: ', num_moves(len(state_zips['FL']),25)
print 'CA: ', num_moves(len(state_zips['CA']),50)
'''
