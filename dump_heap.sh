#!/bin/bash

#script to take a heap dump of running application via command line

#PROCESS is required
PROCESS=""
FILENAME="heapdump-$(date +"%m_%d_%Y_%H%M")"
CONVERT=false
#required flag p: sets the process to dump heap from
#optional flag c indicates that the file should be converted to standard hprof

fileSize() {
	local size=$(echo $(adb shell "ls -s /data/local/tmp/${FILENAME}-unconverted.hprof") | cut -f1 -d' ')
	echo $size
}

waitForFile() {
	# wait for file to stabalize at a size above 0
	local lastSize=0
	local matchCount=0
	while [ ${matchCount} -lt 3 ] ;
	do
		if [[ ${lastSize} -gt 0 && $(fileSize) = ${lastSize} ]] ;
			then
			let "matchCount+=1"
			echo "match ${matchCount}"
		else
			matchCount=0
			lastSize=$(fileSize)
			echo "Dumping file...current size = ${lastSize}"
		fi
		sleep 0.5
	done
	echo "Heap Dump Complete, file size = ${lastSize}"
}

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
waitForFile
adb pull "/data/local/tmp/${FILENAME}-unconverted.hprof"
adb shell "rm /data/local/tmp/${FILENAME}-unconverted.hprof"


if $CONVERT ;
then
	echo "converting to standard hprof"
	hprof-conv -z ${FILENAME}-unconverted.hprof ${FILENAME}-standard.hprof
fi

exit 0