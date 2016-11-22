#!/usr/bin/env python
from os import listdir
from os.path import isfile, join

files = [f for f in listdir(".") if isfile(join(".", f))]
for fname in files:
    if not fname.endswith(".cursor"):
        continue
    print(fname)
    f = open(fname, "r")
    out = open(fname+".new", "w")
    for line in f.readlines():
        try:
            a = line.strip().split()
            size = int(a[0])
            xhot = int(a[1])
            yhot = int(a[2])
        except:
            continue
        new_size = 0
        if size == 24:
            new_size = 64
        elif size == 48:
             new_size = 80
        if new_size:
            xhot = int(float(xhot)/float(size) * new_size)            
            yhot = int(float(yhot)/float(size) * new_size)
            a[0] = str(new_size)
            a[1] = str(xhot)
            a[2] = str(yhot)
        out.write(' '.join(a)+"\n")
        
