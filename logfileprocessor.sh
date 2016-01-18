#!/bin/bash 
# reads the files in the given folder. Folder path given as command line arg to this script
clear
echo "Log processing script invoked....."
echo "Input folder path is $1"
cnt=0
for entry in $1
do
  if [ -f "$entry" ];then
    cnt=$((cnt+1))
    echo "Log file path is $entry and count value is $cnt"
    echo "******** First step started - Log parsing....."
    pig -x local -param "input=$entry" -param "cnt=$cnt" -f logparser.pig
    echo"************ First step completed ****************"
    echo ""
    echo"************ Second step started - Finding min and max value for the log word **************"
    pig -x local -param "cnt=$cnt" -f wordminmax.pig
    echo "************* Second step completed *****************"
    echo ""
    echo "******************** Third step started - Persist detail in Neo4j ***********************"
    pig -x local -param "cnt=$cnt" -f clustergen.pig
    echo "********************** Log file processing completed............."
    echo ""
  fi
done
