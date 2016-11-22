#!/usr/bin/env python
from os import listdir
from os.path import isfile, join
import os

source_path = os.path.dirname(os.path.realpath(__file__))

files = [join(source_path, f) for f in listdir(source_path) if isfile(join(source_path, f))]
for fname in files:
    if not fname.endswith(".cursor"):
        continue
    print(fname)
    f = open(fname, "r")
    out = open(fname.replace(".cursor", ".template"), "w")
    for line in f.readlines():
        try:
            a = line.strip().split()
            size = int(a[0])
            xhot = int(a[1])
            yhot = int(a[2])
        except:
            continue
        new_size = 0
        if size == 64:
            new_size = 100
        elif size == 80:
             new_size = 200
        else:
             print("Unknown size: ", size)
        if new_size:
            xhot = int(float(xhot)/float(size) * new_size)            
            yhot = int(float(yhot)/float(size) * new_size)
            a[0] = str("<small>" if new_size == 100 else "<large>")
            a[1] = str(xhot)
            a[2] = str(yhot)
        out.write(' '.join(a)+"\n")
        
