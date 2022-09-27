import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import datetime
from pathlib import Path

species = 300
iterations = 5000


# Rank the species as the elites
def ranking(weights_list, top=int(0.1 * species)):
    copy_list = {}
    for i in range(len(weights_list)):
        copy_list[i] = weights_list[i]
    # Sort the species and giving it serial num
    ordered_list = sorted(copy_list.items(), key=lambda e: e[1])
    elite_species = [o[0] for o in ordered_list[::-1][:top]]
    # return the serial num of the species
    return elite_species


def distanceFunc(trip, num_city, mode: str):
    total_distance = 0
    for i in range(num_city):
        temp_distance = distance[trip[i]][trip[i + 1]]
        total_distance = total_distance + temp_distance

    if mode == 'fitness':
        return 1 / total_distance
    elif mode == 'distance':
        return total_distance


# Randomly select a num as a node
# Then swap the two sides with the node as a center
def crossover(parent1, parent2):
    num_city = len(parent1)
    rn = random.randint(0, num_city)
    child1 = parent1[0:rn]
    child2 = parent2[0:rn]
    child1.extend(parent2[rn:num_city])
    child2.extend(parent1[rn:num_city])

    # One of the location of the repeated city
    bug1 = []
    bug2 = []
    # Prevent a situation of repeated cities in species
    for i in range(rn, num_city):
        for j in range(rn):
            if child1[i] == child1[j]:
                bug1.append(j)
            if child2[i] == child2[j]:
                bug2.append(j)
    for i in range(len(bug1)):
        child1[bug1[i]], child2[bug2[i]] = child2[bug2[i]], child1[bug1[i]]

    return child1, child2


# Randomly select 2 nodes and reverse the order of city between the nodes
def mutate(sample):
    num_city = len(sample)
    pair = random.sample(range(num_city), 2)
    if pair[0] > pair[1]:
        big = pair[0]
        small = pair[1]
    else:
        big = pair[1]
        small = pair[0]
    after_mutate = sample[0:small]
    temp_mutate = list(reversed(sample[small:big]))
    after_mutate.extend(temp_mutate)
    after_mutate.extend(sample[big:num_city])
    return after_mutate


starttime = datetime.datetime.now()

# Load the data of city
filepath = "D:/Pycharm Projects/ws29.tsp"
load = pd.read_csv(filepath, sep=' ', header=None)
plot = plt.plot(load[1], load[2], '*')

# Calculate the distance。
len_load = len(load)
distance = np.zeros((len_load, len_load))
for i in range(len_load):
    for j in range(len_load):
        temp1 = np.power((load.iloc[i, 1] - load.iloc[j, 1]), 2)
        temp2 = np.power((load.iloc[i, 2] - load.iloc[j, 2]), 2)
        distance[i][j] = np.sqrt(temp1 + temp2)

# Generate the possible solutions
sol = []
counter = 0
while counter < species:
    DNA = np.random.permutation(range(len_load)).tolist()
    start = DNA[0]
    DNA.append(start)
    if DNA not in sol:
        sol.append(DNA)
        counter = counter + 1

iteration_list = []
distance_list = []
times = 0
while times < iterations:
    times = times + 1
    f = []
    for i in range(species):
        f.append(distanceFunc(sol[i], len_load, 'fitness'))
    # Calculate the probability of selection
    sum_f = sum(f)
    weights = (f / sum_f).tolist()

    elite = ranking(weights)
    new_sol = []
    for i in range(len(elite)):
        new_sol.append(sol[elite[i]])
    group = [i for i in range(species)]
    # Roulette Wheel Selection
    survivor = random.choices(group, weights, k=int(0.9 * species))
    for i in range(len(survivor)):
        new_sol.append(sol[survivor[i]])

    m = int(species / 2)
    for i in range(m):
        j = i + m
        if random.randint(1, 10) < 8:
            tplist1 = new_sol[i][0:len(new_sol[0]) - 1]
            tplist2 = new_sol[j][0:len(new_sol[0]) - 1]
            crosslist1, crosslist2 = crossover(tplist1, tplist2)
            if random.randint(1, 10) < 3: 
                crosslist1 = mutate(crosslist1)
                crosslist2 = mutate(crosslist2)
            # Endpoint connects back to startpoint
            crosslist1.append(crosslist1[0])
            crosslist2.append(crosslist2[0])
            new_sol[i] = crosslist1
            new_sol[j] = crosslist2

    sol = new_sol

    result_list = []
    for i in range(species):
        result_list.append(distanceFunc(sol[i], len_load, 'distance'))
    result = min(result_list)

    iteration_list.append(times)
    distance_list.append(result)
#else:
    print(f'Iteration:{times}')
    print(f'Distance:{result}\n')

endtime = datetime.datetime.now()

print(f'Time:{endtime - starttime}')

city_x = []
city_y = []
for i in range(len(sol[0])):
    city_x.append(load.iloc[sol[0][i], 1])
    city_y.append(load.iloc[sol[0][i], 2])

plot = plt.plot(city_x, city_y, c='r')
plt.xlabel('x')
plt.ylabel('y')
plt.title(Path(filepath).stem)
plt.show()

plot = plt.plot(iteration_list, distance_list)
plt.xlabel('Iterations')
plt.ylabel('Distance')
plt.title(f'Total Distance:{result}')
plt.show()
