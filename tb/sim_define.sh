#!/bin/bash

outPath="out"
filePath="./tb/tb_defines.vh"
arg0=$1

if [ ! -d "$outPath" ];then
mkdir $outPath
else
echo ""
fi

if [ ! -f "$filePath" ];then
touch $filePath
echo "\`define $1" > $filePath
else
echo -n "" > $filePath
echo "\`define $1" > $filePath
fi
