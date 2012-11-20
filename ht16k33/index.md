title:	LED dislay Control with the ht16k33
author:	Andrew Smallbone <andrew@phatio.com>
tags: twi, ruby, ht16k33

[datasheet]: http://www.holtek.com/pdf/consumer/ht16K33v110.pdf "datasheet"


# LED display Control with the ht16k33

This guide shows how to communicate with the [HT16K33](http://www.holtek.com/english/docum/consumer/16K33.htm) "RAM Mapping 16*8 LED Controller Driver with keyscan" device, which can control multiple [7 segment LED](http://www.wikipedia.org/wiki/Seven-segment_display) and 8x8 RGY Matrix (3 colour:Red, Green, and Yellow - Red+Green)  using only 2 phatIO pins (plus 5V and GND), in fact upto 8 of these devices can be connected to phatIO whilst only using 2 pins (in the following 4 devices were connected).

Although only available in SMD packages or in small quantities, the HT16K33 is used in popular  
[Adafruit](http://www.adafruit.com/) [LED Matrix](http://adafruit.com/products/902) and [7-Segment](http://adafruit.com/products/1002) 'backpacks'  and other products (what - please [mail](mailto:andrew@phatio.com) if you have links to other products).


This guide concentrates on how to communicate with the HT16K33 from the phatIO it is not an introduction to the internals the HT16K33 device - for that read the [HT16K33 datasheet][datasheet].

Any problems you can [discuss this in the forum](http://www.phatio.com/forum/viewforum.php?f=14&sid=ed2b4cf98744bf2e562f218268f41471).


##Setup

4 phatIO pins are required to communicate with upto 7 HT16K33 devices, wiring is shown below:

![4 pins are required to connect to HT16K33 devices (left) to phatIO (right):  **5V** and **GND**, and **SDA** (pin 13) and **SCL** (pin 12).
These are labelled: **VDD**, **VSS**, **SDA**, and **SCL** on the HT16K33 chips, 
and **+**, **-**, **D**, **C** respectively on Adafruit backpacks.](./connections-75.jpg)


The 8 bit TWI address of the HT16K33 device will be in the form `1000AAAX`, with AAA being the address of the specific chip (see page 26 of the [datasheet]) and X denoting read (1) or write (0).  We'll assume an address of 000 so the TWI address is 0xE0, change the code to reflect your setup.

Multiple HT16K33 devices can be connected to the same 4 pins as long as they have been given different address.


##Initialization
Full configuration code is in the "`examples/ht16k33/run.lio`" copy this to phatIO

	; variable to store address
	(defvar addr 0xE0)

	; write to configuration registers
	(defvar ht16k33_init 
		(twi addr 0x21)
		(twi addr (| 0xE0 15))
		(twi addr (| 0x80 1))
	)

The code above defines a variable to store the device address and then a function to initialize the device by sending 3 TWI messages to setup configuration registers.

**`0x21`**
:	Turns on the system oscillator in the System Setup Register (page 10 of the [datasheet])

**`(| 0xE0 15)`**
:	Sets the LED intensity (page 15 of the [datasheet]), 0 is minimum, 15 is max.  This is logical ORing 0xE0 and 15.

**`(| 0x80 1)`**
:	Turns the display on and blinking off in the Display Setup Register (page 11 of the [datasheet])


##Sending data to the device
The LED displays (discrete, seven segment, or matrix) are controlled by writing to 16 bytes in the HT16K33.  Read the datasheet or your breakout board spec for details.  Using a device driver we can map this to a file:

	(driver ht16k33 
		(= i 0)
		(twi addr 0x00 
			(while (< i 32) 
				(twi_write (read_hexbyte i))
				(= i (+ i 2)) 
			)
		)
	)
	
Once this is running on phatIO, saving the following to file $PHATIO/io/dev/ht16k33

	FF00FF00FF00FF00FF00FF00FF00FF00

would result in the 16 bytes each represented by 2 hex characters in the file ('FF' = 0xFF = 255) being sent to the ht16k33 which it will result in the LEDs lighting appropriately, depending on device.

Note that replacing `read_hexbyte` with `read_byte` and incrementing over each byte the device file we could use raw _binary_ data rather than hexadecimal.

## LED Matrix

### RGY 3 colour matrix (Red, Green, Yellow)

Picture below shows an Adafruit RGY matrix connected when "00FF00FF00FFFFFFFFFFFF00FF00FF00" is written to the device.  Each row is controlled by 2 bytes (FF00 = 0xFF 0x00), the first byte contains a bit for each red LEDs in the column, the second byte for the green LEDs.  So FF00 will make the column red, 00FF green and FFFF yellow (red+green)

![Output of an Adafruit RGY colour matrix with 3 red columns: 00FF, 2 yellow: FFFF, and 3 green: FF00](./rgy-50.jpg)


### Mono matrix

In a mono matrix only the first byte is used (the 2nd byte must be 0x00), we can create another driver to automate this so we only have to write 8 bytes to the device file (called mono) and it _pads_ each byte with 0x00:

	(driver mono
		(= i 0)
		(twi addr 0x00 
			(while (< i 15)
			 	(twi_write (read_hexbyte i) 0x00)
			  	(= i (+ i 2))
			)
		)
	)

The video below shows a small ruby script (`matrix.rb`) writing columns/rows, colours and random data to an RGY and mini mono matrix in turn.  Note that Red and Yellow don't show up that well ont the video.

<iframe style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/IALdMIjbMZI" frameborder="0" allowfullscreen></iframe>

## 7 Segment Displays

Upto 8 7-segment displays can be controlled with an ht16k33, instead of the bits of each byte controlling the pixels of the LED matrix, they control the segments of the display, so 0xFF would turn on all segments, 0x00 turn them off.

![Two 4-digit (plus colon) 7 segment displays](7segment-50.jpg)

`raw-7segment.rb` contains an example ruby script that counts from 0 to 9999 converting the number into correct binary segment values and writing to the `mono` device defined above.


## Self Contained Version

The extract below (in the examples/ht16k33/run.lio) defines a very simple driver which will treat the contents of the device file "`PHATIO/io/dev/time`" as a 4 digit ASCII time converting the digits to the appropriate 7 segment values.  So writing "1234" would result in "12:34" being displayed.

	(defconst cmap 0x3F 0x06 0x5B 0x4F 0x66 0x6D 0x7D 0x07 0x7F 0x6F 0x77)
	(driver time
	 	(twi addr 0x00
			(getvar cmap (- (read_byte 0) '0')) 0x00 ; digit 0
			(getvar cmap (- (read_byte 1) '0')) 0x00 ; digit 1
			0xFF 0x00 ; colon
			(getvar cmap (- (read_byte 2) '0')) 0x00 ; digit 2
			(getvar cmap (- (read_byte 3) '0')) 0x00 ; digit 3
		)
	)


`(- (read_byte 0) '0')` will read the byte at position 0 in the device file (the first character) and subtrace ASCII value '0' from it, this will map character "3" to number 3, "5" to 5 etc.  We then use this as an an index to getvar to get the nth member of the cmap array which is contains which segments to display for the relevant number.  If getvar receives an out of bounds index (less than 0 or greater than 9 in this case) it will return 0 - which will result in a blank digit on the display.  So "  33" and "xx33" would both be shown as "  33" on the display.


Finally the example file contains a very basic `number` device driver, which allows a 4 digit asci number to be written directly to the display:

	echo " 123" > $PHATIO/io/dev/number
	
Also is included is an `address` driver which allows the address of the device to be changed at runtime allowing multiple devices to be addressed - another approach to this would be for the device address to be in the first byte of the device data file. 

A video of both the _manual_ and selfcontained 7 Segment display drivers being driven by the two example ruby scripts is shown below:

<iframe style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/2cYTAcgOel4" frameborder="0" allowfullscreen></iframe>

