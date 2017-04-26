#!/usr/bin/env python
from os import listdir
from os.path import isfile, join
import os
import sys

source_path = os.path.dirname(os.path.realpath(__file__))

small_size = int(sys.argv[1])
large_size = int(sys.argv[2])

files = [join(source_path, f) for f in listdir(source_path) if isfile(join(source_path, f))]
for fname in files:
    if not fname.endswith(".template"):
        continue
    print("%s -> %s [%d %d]" % (fname, fname.replace(".template", ".cursor"), small_size, large_size))
    f = open(fname, "r")
    out = open(fname.replace(".template", ".cursor"), "w")
    for line in f.readlines():
        try:
            a = line.strip().split()
            size = a[0]
            xhot = int(a[1])
            yhot = int(a[2])
        except:
            continue
        new_size = 0
        if size == "<small>":
            new_size = small_size
            size = 100
        elif size == "<large>":
             new_size = large_size
             size = 200
        else:
             print("Unknown size: ", size)
        if new_size:
            xhot = int(float(xhot)/float(size) * new_size)            
            yhot = int(float(yhot)/float(size) * new_size)
            a[0] = str(new_size)
            a[1] = str(xhot)
            a[2] = str(yhot)
        out.write(' '.join(a)+"\n")
        
