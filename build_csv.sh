#!/bin/bash

# Build a query from a folder containing results
# get the directory containing (recursively) the results
resdir=$1

# make a temporary folder for the results
bdir=$(basename $resdir)
tdir="/tmp/clsparse_spmv/$bdir"
echo "Making temp directory: $tdir"
mkdir -p $tdir
csvf=$tdir/results.csv

# grep the results from the folder recursively, 
# and subsitute various parts of it

grep -ra "TIMING_RESULT" $resdir | sed "s/.*TIMING_RESULT:/TIMING_RESULT:/g" > $csvf

cp $csvf .