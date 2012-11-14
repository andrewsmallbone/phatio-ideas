#! /bin/bash
# phatIO pwm larson scanner example
# see http://www.phatio.com/ideas/larson_scanner/
#

if [ ! -d "$PHATIO" ]; then
	echo "set the PHATIO variable to point to your phatIO location"
	exit
fi

SLEEP=0.05
last=(7 8 9 10 6)
values=(250 70 20 4 0)

pulse() {
	for i in {4..1}; do last[$i]=${last[$((i-1))]}; done
	last[0]=$1
	for i in {4..0}; do echo ${values[$i]} > $PHATIO/io/pins/${last[$i]}; done
	sleep 0.1
}

# Set pins to PWM
for pin in {6..10}; do echo PWM > $PHATIO/io/mode/$pin; done

# loop forever
while true; do   
	for pin in {6..10} {9..7} ; do 
		pulse $pin
	done; 
done
