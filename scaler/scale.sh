#!/bin/bash

# test if we have an argument
if [ $# != 2 ]
then
    echo "Error: Wrong number of arguments"
    echo "Example: ./scale.sh <scalingFactor> <schemaWidth>"
    echo "<scalingFactor> is a positive integer"
    echo "<schemawidth> is either 'full' or 'narrow'. 'full' will use a full width vbak/vbap schema, 'narrow' projects to just the necessary columns."
    exit
fi

rm -rf tmp/ && mkdir tmp/
mkdir -p output/
rm -rf output/*.tbl

if [ "$2" = "full" ]
then
  # ALL fields
  vbakfields="1-"
  vbapfields="1-"
elif [ "$2" = "narrow" ]
then
  # project vbap to MANDT, VBELN, MATNR, NETWR, KWMENG
  vbakfields="1,2,3,48"
  # project vbak to MANDT, VBELN, ERDAT, KUNNR
  vbapfields="1,2,4,44,49"
fi

# copy & remove date dashes / copy files
sed s/-//g input/vbap_base.txt | cut -f$vbapfields > tmp/vbap_base.txt
sed s/-//g input/vbak_base.txt | cut -f$vbakfields > tmp/vbak_base.txt
sed 's/-//g' input/kna1.txt | sed 's/\t/|/g' > tmp/kna1.tbl
sed 's/-//g' input/makt.txt | sed 's/\t/|/g' > tmp/makt.tbl
sed 's/-//g' input/mara.txt | sed 's/\t/|/g' > tmp/mara.tbl
sed 's/-//g' input/adrc.txt | tr -d '|' | sed 's/\t/|/g' > tmp/adrc.tbl

python scaler.py $1

# prepend schema info
cut -d "|" -f$vbapfields schema/vbap_base_schema.txt > output/vbap.tbl
cut -d "|" -f$vbakfields schema/vbak_base_schema.txt > output/vbak.tbl
cp schema/kna1_schema.txt output/kna1.tbl
cp schema/makt_schema.txt output/makt.tbl
cp schema/mara_schema.txt output/mara.tbl
cp schema/adrc_schema.txt output/adrc.tbl

# append results
cat tmp/vbap_base.tbl >> output/vbap.tbl
cat tmp/vbak_base.tbl >> output/vbak.tbl
cat tmp/kna1.tbl >> output/kna1.tbl
cat tmp/makt.tbl >> output/makt.tbl
cat tmp/mara.tbl >> output/mara.tbl
cat tmp/adrc.tbl >> output/adrc.tbl
