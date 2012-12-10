title:	Multiplexing 7-Segment Displays
author:	Andrew Smallbone <andrew@phatio.com>
tags:	7segment, led, 


# Multiplexing 7-Segment Displays

This page shows how to connect a multi digit [7 segment](http://en.wikipedia.org/wiki/Seven-segment_display) display to phatIO.  Each digit has 7 (or 8 including the decimal point) pins.  So 2 digits could be controlled directly using 16 of phatIO's 20 IO pins.  To control more requires multiplexing the digits - using the same pins connected to the same segment on all digits and use a pin to turn on each digit.  The required segments on each digit are lit in turn very quickly.  Persistence of Vision eliminates the _flicker_.

For optimum performance with controllable intensity control of 7 segment displays a driver chip should be used such as the MAX7219 or [ht16k33](../ideas/ht16k33/)

Resources are in the side bar or can be found in the 
[repository](http://www.github.com/phatio/ideas/7segment/resources/)


##Setup

The 7 Segment LED display used was obtained from ebay - a fairly low intensity yellow 4 digit display with no decimal point, just a colon and 3 'icons' ("mail", "sound", "BYPASS").

![7 Segment display on a breadboard connected to phatIO](breadboard-75.jpg)


The circuit used is shown below, the common segment LED pins (a to g) are connected via a resistor to pins 0..7 on phatIO.  The resistor value can be lower than if the LEDs were being lit permanently - they are only being powered atmost 25% of the time due to the multiplexing.  You can do the math to calculate accurately if trying to power upto the maximum, but as I wanted a more subdued output I just used trial and error to reduce the current until I got a suitably bright display.

The display used was a common anode variety.  That is, the anode/digit select pin has to be high and the segment pin low for current to flow through the LED and the segment to be lit.  Even with a fairly low current LED being used if all are on it can consume more current than is possible to (safely) source from one of the phatIO pins.  A PNP transistor is used, with the phatIO pin being used to switch the transistor on and off - this has the result that both segment and digit pins need to be low - 0 for the respective LED to light.

![Rought circuit used to connect the 7 segment display to phatIO.  Segment LEDs (via a resistor) to pins 0..6.  The digit selector pins (1, 2, 3, & 4) to pins 7..10 via a PNP transistor](circuit-100.jpg)

Circuit used is shown below.  The connections for the colon and icons aren't shown, these have a cathode/anode pin on the other side of the display, the cathodes were connected to ground and anodes to pins 11..14 via resistor.

There's lots of LED biasing and multiplexing background information on the internet, including the following:

1.	[Wikipedia 7 segment display](http://en.wikipedia.org/wiki/Seven-segment_display)
2.  [Wikipedia LED circuit](http://en.wikipedia.org/wiki/LED_circuit)
3.  [Atmel App note 242 - Multiplexing LED drive](http://www.atmel.com/images/doc1231.pdf)


##Code

The config in phatIO is fairly simple, we define an array (`data`) of bytes to hold the segment bit values: segment 'a' at bit 0, segment 'b' at bit 1, upto segment 'g' at bit 6.  Bit 7 is unused in this example but would store the decimal point if used.

The variable `digit` is used to remember the current digit being displayed.  Every millisecond the current digit is incremented and we light the LED segments for it:

1.	Turn off current LED digit (set the anode/transistor driver pin high)
2.	Increment `digit` to the next digit
3.  Get the data for the current digit and output to the cathode pins (0..6)
4.  Turn on the new digit (set the anode/transistor driver pin low)

Code follows (full version in the resources sidebar):


	(defvar data 0xFF 0xFF 0xFF 0xFF)
	(defvar digit 0)
	(every 1
	 	(setpin (+ 7 digit) 1)
	 	(if (eq digit 3) (= digit 0) (+= digit 1))
	 	(port (getvar data digit) 0 1 2 3 4 5 6)
	    (setpin (+ 7 digit) 0)
	)

To change the value being displayed a simple driver converts a 4 digit ASCII number to the relevent 7 segment data

	(defconst cmap 0xC0 0xF9 0xA4 0xB0 0x99 0x92 0x82 0xF8 0x80 0x90);
	(driver number
		(= i 0)
		(while (< i 4) 
			 (= data i (getvar cmap (- (read_byte i) '0')))
			 (if (eq 0 (getvar data i)) (= data i 0xFF))
			 (+= i 1))
	)
	
Any non digits will be represented by a blank.  The following video shows the result of the display being incremented every second from the host computer.  Note the slight flicker as the digits change, this is due to the display multiplexing not happening whilst the file is being updated.

<iframe width="560" height="315" style="display: block; margin-left: auto; margin-right: auto" src="http://www.youtube-nocookie.com/embed/IOb7x7T9yvM" frameborder="0" allowfullscreen></iframe>




