#!/bin/bash
sizes=(100000 500000 1000000 5000000 10000000 50000000)

for size in "${sizes[@]}"
do
    head -n $size output/vbap_base_project.tbl > output/vbap_base_project_$size.tbl
    vbaksize=`echo "scale=0; 0.446*$size/1" | bc`
    head -n $vbaksize output/vbak_base_project.tbl > output/vbak_base_project_$size.tbl
done
