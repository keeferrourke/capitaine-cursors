import os

for path in os.listdir("config"):
    r_file = open("config/" + path, 'r')
    w_file = open("configw/" + path, 'w+')
    lines = r_file.readlines()
    bases = lines[:int(len(lines) / 2)]

    for x in (1, 1.25, 1.5, 2):
        for line in bases:
            tokens = line.split()
            new = [
                      str(int(int(tokens[0]) * x)),
                      str(int(int(tokens[1]) * x)),
                      str(int(int(tokens[2]) * x)),
                      "x%s/%s" % (str(x), tokens[3].split('/')[1])
                  ] + tokens[4:]
            print(' '.join(new))
            w_file.write(' '.join(new))
            w_file.write('\n')
    r_file.close()
    w_file.close()
