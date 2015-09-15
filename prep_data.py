import json


with open('./data/zipcode.csv', 'r') as f:
    zipcodes = f.readlines()

with open('./data/pop_zip_2010.csv', 'r') as f:
    population = f.readlines()

print len(zipcodes)
print zipcodes[:3]
# '"zip","city","state","latitude","longitude","timezone","dst"\n'

print len(population)
print population[:3]
# 'zip,population\r\n'

print '\n\n'


print zipcodes[3].split(',')


# Use pre-made R code to skip
