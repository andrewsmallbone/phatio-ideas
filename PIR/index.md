title:	Passive Infra Red Sensors
author:	Andrew Smallbone <andrew@phatio.com>
tags:	pir, keyboard


# Passive Infra Red Sensors

This short document illustrates how to connect a [passive infrared sensor (PIR sensor)](http://en.wikipedia.org/wiki/Passive_infrared_sensor) to phatIO.  In particular the small
self contained modules that output a digital signal when movement is detected.  These are available widely (For example: [Adafruit](http://www.adafruit.com/products/189), [Sparkfun](https://www.sparkfun.com/products/8630), and [Ebay](http://www.ebay.com/sch/i.html?_sacat=0&_from=R40&_nkw=PIR+motion+detector+module+sensor&_sop=15))

The device used was obtained from Ebay for $1.50 USD including shipping from China.  It took nearly a month to arrive and the capacitors at the corners of the board had got a little bent in shipping but the device worked perfectly.  Devices shipped from the larger resellers are more likely to arrive sooner and in working order.

![Both sides of the PIR detector.  Left image shows the two orange sensitivy trimpots.  The right the GND, OUT, and +5V pins.  To use with phatIO simply connect the +5V and GND pins to the phatIO power pins and OUT to any phatIO IO pin configured as an INPUT.](pir-100.jpg)

The PIR device has 3 pins: 5V, GND, and OUT.  When connected to phatIO's 5V and GND pins the OUT pin will be at 0V until movement is detected, it then goes to 3V - this is high enough to be read as a digital 1 by phatIO when connected to one of its IO pins.
The PIR modules 'time' and 'sensitivity' trimpots can be used to alter how long the PIR OUT pin stays high and how soon it will detect movement respectively.  I found the default values to be fine.

Config for the following examples is in the sidebar on the right of this page or downloadable from the [repository](http://www.github.com/phatio/ideas/PIR/resources/)


##Basic Usage

Basic phatIO config for a PIR device on pin 0 of phatIO is shown below ([copy](http://www.github.com/phatio/ideas/PIR/resources/basic.lio) to `run.lio` on your phatIO device)

	(defconst PIR 0)
	(pinmode PIR IN)

	(defconst LED 1)
	(pinmode LED OUT)

	(pin_goes_high PIR 
		(keyboard "movement!")
		(setpin LED 1))

	(pin_goes_low PIR (setpin LED 0))

The above simply lights an LED (on pin 1) on detection of movement and types "movement!".  The LED is turned off when the PIR pin goes low.  


##Turn off Computers Screen Saver

The phatIO config below ([copy](http://www.github.com/phatio/ideas/PIR/resources/wakeup.lio) to `run.lio` on your phatIO device)
will send a shift key to the computer when it detects movement after 60 seconds of no movement.

This is useful used in conjunction with a screen saver to turn off your monitor after a few minutes of inactivity (when you walk away from the computer) but keep it on whist moving around your desk or walk back into range.

	(defconst PIR 0)
	(pinmode PIR IN)

	(defconst QUIET 60)

	(defvar quiet 0)
	(pin_goes_high PIR 
		(if (> quiet QUIET)
			((keyboard "%{LeftShift}")
	  		 (= quiet 0))
		)
	)

	(pin_goes_low PIR	(= quiet 1))

	; every second increment 'quiet' if no movement is detected.
	(every 1000
	 	(if quiet (+= quiet 1))
	)

## Other Ideas

Using techniques from [Keyboard Hacks](/ideas/keyboard/) to launch applications on the host computer it would be possible to make the host computer capture an image with a webcam when it detects movement (see [CommandCam](http://batchloaf.wordpress.com/commandcam/) and [imagesnap](http://www.iharder.net/current/macosx/imagesnap/)).


A count of movements could be displayed using one of the 7 segment or LCD display examples (See [LED display Control with the ht16k33](/ideas/ht16k33/), [Multiplexing 7-Segment Displays](/ideas/7segment/), and [LCD Displays](/ideas/HD44780/)).  
For example, the following increments a 'count' variable and displays the 4 digits on a [TWI 7 segment display](/ideas/ht16k33/#segmentdisplays) each time movement is detected:

	(defvar data "    ")
	(defvar count 0)
	
	; map of digits to 7 segment display bytes
	(defconst cmap 0x3F 0x06 0x5B 0x4F 0x66 0x6D 0x7D 0x07 0x7F 0x6F 0x77)
	
	; called when PIR pin goes high - motion detected.
	(pin_goes_high PIR 
		; increment the count and convert to 4 characcter string
		(= data (fmt "%4d" (+= count 1)))

		; send the data to twi display
	    (twi addr 0x00
	        (getvar cmap (- (getvar data 0) '0')) 0x00
	        (getvar cmap (- (getvar data 1) '0')) 0x00
	        (getvar cmap (- (getvar data 2) '0')) 0x00
	        (getvar cmap (- (getvar data 3) '0')) 0x00
		)
	)



