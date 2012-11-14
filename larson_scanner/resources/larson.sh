#! /bin/bash
# phatIO larson scanner example
# see http://www.phatio.com/ideas/larson_scanner/
#

if [ ! -d "$PHATIO" ]; then
	echo "set the PHATIO variable to point to your phatIO location"
	exit
fi

SLEEP=0.05

# Set pins to outputs
for pin in {0..11}; do echo OUT > $PHATIO/io/mode/$pin; done
# loop forever
while true; do   
	for pin in {0..11} {10..1} ; do 
		echo 1 > $PHATIO/io/pins/$pin; # turn on led
		sleep $SLEEP; # sleep a little
		echo 0 > $PHATIO/io/pins/$pin; # turn off led
	done; 
done
