#!/bin/bash

# test if we have an argument
if [ $# != 1 ]
then
    echo "Error: First argument must be scaling factor"
    echo "Example: ./scale.sh 100"
    exit
fi

rm -rf tmp/ && mkdir tmp/
rm -rf output/ && mkdir output/

# copy & remove date dashes / copy files
sed s/-//g input/vbap_base_project.txt > tmp/vbap_base_project.txt
sed s/-//g input/vbak_base_project.txt > tmp/vbak_base_project.txt
sed 's/-//g' input/kna1.txt | sed 's/\t/|/g' > tmp/kna1.tbl
sed 's/-//g' input/makt.txt | sed 's/\t/|/g' > tmp/makt.tbl
sed 's/-//g' input/mara.txt | sed 's/\t/|/g' > tmp/mara.tbl
sed 's/-//g' input/adrc.txt | tr -d '|' | sed 's/\t/|/g' > tmp/adrc.tbl 

# MARA: MATNR
python scaler.py $1

# prepend schema info
cp schema/vbap_base_project_schema.txt output/vbap.tbl
cp schema/vbak_base_project_schema.txt output/vbak.tbl
cp schema/kna1_schema.txt output/kna1.tbl
cp schema/makt_schema.txt output/makt.tbl
cp schema/mara_schema.txt output/mara.tbl
cp schema/adrc_schema.txt output/adrc.tbl

# append results
cat tmp/vbap_base_project.tbl >> output/vbap.tbl
cat tmp/vbak_base_project.tbl >> output/vbak.tbl
cat tmp/kna1.tbl >> output/kna1.tbl
cat tmp/makt.tbl >> output/makt.tbl
cat tmp/mara.tbl >> output/mara.tbl
cat tmp/adrc.tbl >> output/adrc.tbl
