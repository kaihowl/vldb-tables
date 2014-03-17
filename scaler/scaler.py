import random
import sys

def scale(multiplier, indir,fields,infile):
    counter = 0
    outstream = open(indir+infile.replace(".txt",".tbl"),"w")
    instream = open(indir+infile,"r")
    for line in instream:
        while counter < multiplier:
            array = line.split("\t")
            if counter != 0:
                for field in fields:
                    if len(array[field]) > 0:
                        array[field] = str(counter)+array[field]
            outstream.write("|".join(array))
            counter = counter + 1
        # next line
        counter = 0

indir = "./tmp/"

ifiles = [["vbak_base.txt", [1]], ["vbap_base.txt", [1]]]

if __name__ == "__main__":
    for elem in ifiles:
        scale(int(sys.argv[1]),indir,elem[1],elem[0])
