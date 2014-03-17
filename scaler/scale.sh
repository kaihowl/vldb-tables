#!/bin/bash

# test if we have an argument
if [ $# != 1 ]
then
    echo "Error: First argument must be scaling factor"
    echo "Example: ./scale.sh 100"
    exit
fi

rm -rf tmp/ && mkdir tmp/
mkdir -p output/
rm -rf output/*.tbl

# copy & remove date dashes / copy files
# project vbap to MANDT, VBELN, MATNR, NETWR, KWMENG
sed s/-//g input/vbap_base.txt | cut -f1,2,4,44,49 > tmp/vbap_base_project.txt
# project vbak to MANDT, VBELN, ERDAT, KUNNR
sed s/-//g input/vbak_base.txt | cut -f1,2,3,48 > tmp/vbak_base_project.txt
sed 's/-//g' input/kna1.txt | sed 's/\t/|/g' > tmp/kna1.tbl
sed 's/-//g' input/makt.txt | sed 's/\t/|/g' > tmp/makt.tbl
sed 's/-//g' input/mara.txt | sed 's/\t/|/g' > tmp/mara.tbl
sed 's/-//g' input/adrc.txt | tr -d '|' | sed 's/\t/|/g' > tmp/adrc.tbl

python scaler.py $1

# prepend schema info
cut -d "|" -f1,2,4,44,49 schema/vbap_base_schema.txt > output/vbap.tbl
cut -d "|" -f1,2,3,48 schema/vbak_base_schema.txt > output/vbak.tbl
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
