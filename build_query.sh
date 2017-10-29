#!/bin/bash

# Build a query from a folder containing results
# get the directory containing (recursively) the results
resdir=$1
# get the name of a table to insert into
table=$2

# make a temporary folder for the results
bdir=$(basename $resdir)
tdir="/tmp/clsparse_spmv/$bdir"
echo "Making temp directory: $tdir"
mkdir -p $tdir
qfile=$tdir/query.sql

# grep the results from the folder recursively, 
# and subsitute various parts of it

grep -ra "INSERT" $resdir | sed "s/.*INSERT/INSERT/g" | sed "s/table_name/$table/g" > $qfile

cp $qfile .
