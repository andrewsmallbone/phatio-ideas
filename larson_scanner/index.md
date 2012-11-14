title:	phatIO Larson Scanner
author:	Andrew Smallbone <andrew@phatio.com>
tags:	leds, pwm, ruby, shell, lio


# Larson Scanner

Note this guide is currently a little linux/osx specific - Only bash shell and ruby sample code is shown.  Windows example code will be added.  Please contribute and give feedback.


This guide shows various ways of making a simple Larson Scanner with phatIO - a row of lights that scan back and forth, named after [Glen A. Larsen](http://en.wikipedia.org/wiki/Glen_A._Larson) creator of [Knight Rider](http://en.wikipedia.org/wiki/Knight_Rider_(1982_TV_series)) which features a scanner on the front of [KITT](http://en.wikipedia.org/wiki/KITT).

This code is in the examples/larson_scanner/ directory on your phatIO or in the [repository](http://www.github.com/phatio/phatIO/examples/larson_scanner)

##Basic Setup
We'll be using Light Emitting Diodes, connected to phatIO's IO pins.  See the [LED Guide page](../../guide/leds.html) for information on how to connect LEDs - make sure they're biased correctly.  The examples below are on a breadboard and use red 3mm, 5V, 10mA, LEDS connected to pins 0 through 11, but you can extend to use all available IO pins as long as maximum current is not exceeded.

![12 5V LEDs with Anodes (Long Leg) connected to phatIO's top IO pins 0..11 and Cathodes (short leg) connected to ground.  Make sure your LEDs are biased correctly.](setup-50.jpg)


In any code listed below `PHATIO` should be replaced with the location of your phatIO mount point: for example "`/Volumes/PHATIO`", "`/mnt/PHATIO`", "`P:`"

The following contains lots of Operating System and language specific code - see the [Host Computer](../../guide/os_specifics.html) page for general  information about using phatIO with your operating system.  The *nix shell and ruby code runs on your host computer (the Mac/PC/linux box  your phatIO is connected to).  The `run.lio` code should be copied to the "`PHATIO/io/run.lio`" location on your phatIO device.


##Basic Digital Version

On unix based operating systems with a bash shell a command line version is trivial, we turn all pins to outputs and then
loop from 0 through 11 and back down again turning the LED on, sleeping for a little while, and then turning off the LED:

	# Set pins to outputs
	for pin in {0..11}; do echo OUT > $PHATIO/io/mode/$pin; done
	# loop forever
	while true; do   
		for pin in {0..11} {10..1} ; do 
			echo 1 > $PHATIO/io/pins/$pin; # turn on led
			sleep 0.05; # sleep a little
			echo 0 > $PHATIO/io/pins/$pin; # turn off led
		done; 
	done

Ruby is similar:

	BOTTOMLED=0
	TOPLED=11
	PHATIO=ENV['PHATIO']
	... # see examples/larson/larson.rb for io code
  
	def flash(pin)
  		pin(pin, 1)
  		sleep 0.05
  	  	pin(pin, 0)
	end

	BOTTOMLED.upto(TOPLED) { |pin| mode(pin, "OUT") }
	while true
  		BOTTOMLED.upto(TOPLED) { |pin| flash(pin)}
  	  	TOPLED.downto(BOTTOMLED) { |pin| flash(pin)}
	end


Resulting output is shown below:

<iframe  style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/EZmZIUKY9oc" frameborder="0" allowfullscreen></iframe>

##PWM Version
Pins 6 through 10 are PWM capable, so we can create a more 'analog' version using these pins with the leading LED leaving a trail of light.
Here's a shell version:

	SLEEP=0.05
	last=(7 8 9 10 6)
	values=(250 70 20 4 0)

	pulse() {
		for i in {4..1}; do last[$i]=${last[$((i-1))]}; done
		last[0]=$1
		for i in {4..0}; do 
			echo ${values[$i]} > $PHATIO/io/pins/${last[$i]};
		done
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

And a ruby version:

	# history of which pins have been lit
	$trail = [7, 8, 9, 10, 6]
	# intensities of LED in trail
	$values = [250, 70, 20, 4, 0]

	def pulse(pin)
		4.downto(1) { |x| $trail[x] = $trail[x-1] }
		$trail[0] = pin
		4.downto(0) { |x| pin($trail[x], $values[x]) }
		sleep 0.1
	end  

	# pwm pins are 6 7 8 9 10
	6.upto(10) {|p| mode(p, "PWM") }
	while true
  		[6,7,8,9,10,9,8,7].each{ |x| pulse(x) }
	end

The code remembers the history `trail` of pin ids and gives each a PWM intensity from the `values` array: 250 for the current LED, 70 for the next down to 0 for the last.  You may have to tweak these PWM intensity values to get a nice looking output with your specific LEDs.
Here's a video:

<iframe  style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/fcjMdHSUNGA" frameborder="0" allowfullscreen></iframe>


## Self Contained Version

The simple scanning is something that the phatIO config language can do onboard, here's an example run.lio (copy to "`PHATIO/io/run.lio`") that does
the simple digital scanning.  Note that there's no sleep calls available - the code is scheduled to execute every 20 milliseconds, it turns the current pin off, checks if we're at the end of the row of LEDS and changes direction (sets the increment value to 1 or -1 accordingly) and then turns on the new LED.

	; copy this to your phatIO device: PHATIO/io/run.lio
	(defvar current 0)   # the current LED
	(defvar direction 1) # 1=up -1=down

	; set pins 0..11 as outputs and turn off
	(while (< current 12)
		(pinmode current OUT 0)
		(+= current 1)
	)

	; every 25ms turn off current LED and turn on next
	(every 25
		(setpin current 0)
		(if (> current 10) 
			(= direction -1))
		(if (eq current 0) 
			(= direction 1))
		(+= current direction)
		(setpin current 1)
	)

Here's a video (after 10 seconds I save the `run.lio file` with a 50ms delay between each LED change and then reduce it down to 1ms where the scan can no longer be seen.
<iframe  style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/WLpbl8AtLM4" frameborder="0" allowfullscreen></iframe>


