#!/bin/bash

# Creates vbap and corresponding vbak tbl files for all sizes in output-range/
# Instead of scaling all for all numbers individually, only the biggest tables
# are created and the remainder is just the head of those tables..
# Call like ./create-range.sh <vbap_size_1> <vbap_size_2> ...  # <vbap_size_n>
# vbap_size_1 has to be the biggest size

set -e

function usage() {
  echo You have to supply a range of vbap sizes!
  echo ./create-range.sh \<vbap_size_1\> \<vbap_size_2\> \.\.\.  \# \<vbap_size_\>
  echo vbap_size_1 has to be the biggest size!
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

if [ -d output-range ]; then
  echo Delete the output-range/ dir first to confirm regeneration!
  exit 1
fi

./scale.sh 1 narrow
unary_vbap_size=$(wc -l < output/vbap.tbl)
unary_vbak_size=$(wc -l < output/vbak.tbl)
scale_factor=$(echo "($1 - 4) / $unary_vbap_size + 1" | bc)

echo The scale factor for size $1 is $scale_factor

printf "Beginning to scale vbap and vbak... "

./scale.sh $scale_factor narrow

echo "Done!"

mkdir output-range

for size in "$@"; do
  printf "Outputting tables for size $size... vbap "
  head -n $size output/vbap.tbl > output-range/vbap_$size\.tbl

  vbak_vbap_ratio=$(echo "scale=5; $unary_vbak_size / $unary_vbap_size" | bc)
  # Division by zero and default scale=0 rounds down
  vbak_size=$(echo "$vbak_vbap_ratio * $size / 1" | bc)

  printf "vbak "
  head -n $vbak_size output/vbak.tbl > output-range/vbak_$size\.tbl

  echo "--> done!"
done;

echo Done! Find the results in output-range.

