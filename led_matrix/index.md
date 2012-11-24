title:	Simple Control of LED Matrix
author:	Andrew Smallbone <andrew@phatio.com>
tags: led

__This Document is not complete__, the code works and is tested but documentation is not finished and complete.

This shows how to control a simple LED matrix directly from phatIO, a more optimal approach is to use a driver chip such as the [ht16k33](/ideas/ht16k33) or [MAX7219](http://www.maximintegrated.com/datasheet/index.mvp/id/1339)

# Simple Control of LED Matrix

##Setup

Photo of the setup is below:

![Wiring for the LED Matrix - it fits over the lower portion of the bread board.](setup-80.jpg)

__Description TBD__

I'm using only the red LEDs of a Red/Green LED matrix (pinout below) with suitable current limiting resistors (180 ohms to give about 18mA flowing through the 1.8V red LED).

![Pinout of LED Matrix used - only the red LEDs were connected](pinout-50.jpg)


Anodes are connected to phatIO pins 0..7 and cathodes to pins 12..19.


##Controlling the device

By setting the 8 pins connected to the matrix LED anodes (rows) and 8 pins connected to cathodes (columns) all as digital outputs we can turn an LED on by setting its row pin HIGH and column pin low so that 5V flows through it (plus the resistor).
We can only control 8 LEDs at a time - the others will be off.  But if we scan through each row fast enough, persistance of vision will make it look as if all LEDs are lit.  Note that the terms rows and columns are arbitrary depening on orientation of the LED matrix and how its connected.

The code below (see run.lio in the box to the right) creates an array - `rows` to hold the values of the LEDs in each row, a `row` variable to remember the current row and a scheduled event that runs every 3 milliseconds.

	(defvar rows 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF)
	(defvar row 0); current row

	; every 3 milliseconds show a new row
	(every 3
       (setpin row 0); 
       (= row (if (eq row 7) 0 (+ row 1)))
	   (port (getvar rows row) 12 13 14 15 16 17 18 19)
       (setpin row 1)
	)

Every 3 milliseconds the code turns off the current row (because pins 0..7 control the rows - `(setpin 3 0)` will turn off row 3), increments the row variable, set the column pins according using the [port](/guide/lio/io/#port) function to automatically output each bit of the first argument to the pins passed as the rest, the new row pin is then turned on.


A Simple driver allows us to read the value of the matrix from a file (`PHATIO/io/dev/matrix`).  The following driver assumes hex contents with 2 characters for each row "FFFFFFFFFFFFFFFF" would turn on all LED's "FF00FF00FF00FF00" would give a stripes in one direction and "AAAAAAAAAAAAAAAA" in another:

	(driver matrix 
		(= i 0)
		(while (< i 8)
		       (setvar rows i (~ (read_hexbyte (* i 2))))
			   (+= i 1))
	)

Picture below shows an example output.  A certain amount of flicker results when the matrix file is written to as it interrupts the scanning - a better approach would be to use a driver chip to do the scanning.

![LED matrix when "00003C3C3C3C0000" is written to the device file](result-50.jpg)
