#!/bin/bash

#script to take a heap dump of running application via command line

#NOTE this currently has problems where adb pull grabs an empty file

#PROCESS is required
PROCESS=""
FILENAME="heapdump-$(date +"%m_%d_%Y_%H%M")"
CONVERT=false
#required flag p: sets the process to dump heap from
#optional flag c indicates that the file should be converted to standard hprof

while getopts 'p:c' opt;
do
	case $opt in
	p)
		PROCESS=${OPTARG}
		;;
	c) 
		CONVERT=true
		;;
	esac
done

if [ -z $PROCESS ];
then
	echo "ERROR: You must enter a process name by using -p {process}"
	exit 1
fi

echo "dumping heap of ${PROCESS} to file: ${FILENAME}"
adb shell "am dumpheap ${PROCESS} /data/local/tmp/${FILENAME}-unconverted.hprof"
adb pull "/data/local/tmp/${FILENAME}-unconverted.hprof"
adb shell "rm /data/local/tmp/${FILENAME}-unconverted.hprof"


if $CONVERT ;
then
	echo "converting to standard hprof"
	hprof-conv -z ${FILENAME}-unconverted.hprof ${FILENAME}-standard.hprof
fi

exit 0