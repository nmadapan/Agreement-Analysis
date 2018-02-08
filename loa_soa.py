import os
from itertools import combinations
from scipy.spatial.distance import pdist
import numpy as np

base_dir = ".\\Videos_SortBy_Commands_34"

dirs = os.listdir(base_dir)

#count = 0
num_subs = 9
num_cmds = 34

loa_list = [0 for i in range(num_cmds)]
loa_onehot_list = [0 for i in range(num_cmds)]
loa_mod_alone_list = [0 for i in range(num_cmds)]
loa_mod_alone_onehot_list = [0 for i in range(num_cmds)]

loa_con_alone_list = [0 for i in range(num_cmds)]
loa_con_alone_onehot_list = [0 for i in range(num_cmds)]

#metric = 'jaccard'
# Jaccard metric is used by default.

for dir in dirs:
    cmd_idx = int(dir.split('_')[0])
    file_path = os.path.join(base_dir, dir, "annot.txt")
    #print file_path
    con_list = []
    mod_list = []

    nul_con_list = []

    with open(file_path, 'r') as fid:
        for line in fid:
            line = line.strip()
            if len(line)>0:
                if not line[0].isdigit():
                    flag = line[0].lower()
                    continue
            else:
                continue

            if flag == 'c' and len(line)>0:
                con_list.append(list(map(int,line.split(' '))))
            if flag == 'm' and len(line)>0:
                mod_list.append(list(map(int,line.split(' '))))
            if flag == 'n' and len(line)>0:
                nul_con_list.append(list(map(int,line.split(' '))))

    #print con_list
    #print mod_list
    #print nul_con_list

    gest_ids = [i+1 for i in range(num_subs)]
    gest_flag = 1
    for mod in mod_list:
        for con in con_list:
            temp = list(set.intersection(set(con),set(mod)))
            if len(temp) == 0:
                continue
            for val in temp:
                gest_ids[val-1] = gest_ids[temp[0]-1]
        for nul in nul_con_list:
            temp = list(set.intersection(set(nul),set(mod)))
            if len(temp) == 0:
                continue
            for val in temp:
                gest_ids[val-1] = gest_ids[temp[0]-1]

    #print gest_ids


    # Finding the LOA using SOA
    temp = set()
    loa = 0.0
    loa_onehot = 0.0
    for idx in range(num_subs):
        if gest_ids[idx] not in temp:
            cnt = gest_ids.count(gest_ids[idx])
            loa = loa + float(cnt) ** 2.0
            loa_onehot = loa_onehot + len(list(combinations(range(cnt), 2)))
            temp.add(gest_ids[idx])

    loa = loa / float(num_subs*num_subs)
    loa_onehot = float(loa_onehot) / float(len(list(combinations(range(num_subs), 2))))

    loa_list[cmd_idx-1] = float('%.2f'%loa)
    loa_onehot_list[cmd_idx-1] = float('%.2f'%loa_onehot)


    # Modifier alone using SOA
    loa_mod_alone = (sum([(len(mod))**2-len(mod) for mod in mod_list])+num_subs) / float(num_subs*num_subs)

    loa_mod_alone_list[cmd_idx-1] = float('%.2f'%loa_mod_alone)

    #Modifier alone using one hot vectors
    loa_mod_alone_onehot = sum([len(list(combinations(range(len(mod)),2))) for mod in mod_list]) / float(len(list(combinations(range(num_subs), 2))))
    loa_mod_alone_onehot_list[cmd_idx-1] = float('%.2f'%loa_mod_alone_onehot)


    #Context alone using SOA
    loa_con_alone = (sum([(len(con))**2-len(con) for con in con_list])+num_subs) / float(num_subs*num_subs)

    loa_con_alone_list[cmd_idx-1] = float('%.2f'%loa_con_alone)

    #Context alone using one hot vectors
    loa_con_alone_onehot = sum([len(list(combinations(range(len(con)),2))) for con in con_list]) / float(len(list(combinations(range(num_subs), 2))))
    loa_con_alone_onehot_list[cmd_idx-1] = float('%.2f'%loa_con_alone_onehot)


    fid.close()

print 'Context alone - state of the art'
print loa_con_alone_list
print np.mean(loa_con_alone_list), np.std(loa_con_alone_list)
print '--------------------------------'

print 'Context alone - oen hot'
print loa_con_alone_onehot_list
print np.mean(loa_con_alone_onehot_list), np.std(loa_con_alone_onehot_list)
print '--------------------------------'

print 'Modifier alone - state of the art'
print loa_mod_alone_list
print np.mean(loa_mod_alone_list), np.std(loa_mod_alone_list)
print '--------------------------------'

print 'Modifier alone - one hot'
print loa_mod_alone_onehot_list
print np.mean(loa_mod_alone_onehot_list), np.std(loa_mod_alone_onehot_list)
print '--------------------------------'

print 'Modifier + Context - State of the Art'
print loa_list
print np.mean(loa_list), np.std(loa_list)
print '--------------------------------'

print 'Modifier + Context - One hot vector representation'
print loa_onehot_list
print np.mean(loa_onehot_list), np.std(loa_onehot_list)
print '--------------------------------'
