title:	LCD Displays
author:	Andrew Smallbone <andrew@phatio.com>
tags:	lcd, HD44780


# LCD Displays

This shows how to map a [HD44780](http://en.wikipedia.org/wiki/Hitachi_HD44780_LCD_controller) based LCD panel (most LCD panels use the HD44780) to a file on phatIO.  So you can save "Hello  World" to the file and "Hello  World" will be displayed on the LCD panel.

<iframe width="560" height="315" style="display: block; margin-left: auto; margin-right: auto" src="http://www.youtube-nocookie.com/embed/BDEfdRqanss" frameborder="0" allowfullscreen></iframe>

The phatIO driver is still fairly basic, uses the full 8-bit databus and just maps the HD44780 display RAM to file, but does provide ability to process newlines automatically.  An updated driver will be posted later with support for 4-bit databus and using custom fonts.

Copy run.lio in the resources sidebar to your phatIO device (from the sidebar or browse the [repository](http://www.github.com/phatio/ideas/HD44780/resources/))


##Hardware

All you need is a phatIO, a HD44780 Display, connection cable, and optionally a potentiometer to adjust contrast.

HD44780 displays are available in a range of sizes and colours from just about all distributors ([Adafruit](https://www.adafruit.com/), [Sparkfun](https://www.sparkfun.com/search/results?term=HD44780&what=products), [Digikey](http://www.digikey.com/scripts/dksearch/dksus.dll?FV=fff40008%2Cfff80095&k=LCD&PV154=503), even [Ebay](http://www.ebay.com/sch/i.html?&_nkw=HD44780))


HD44780 LCDs have 16 control pins, numbered 1-16.  This example connects them to the phatIO as follows.


|LCD pin | LCD pin description | phatIO pin |
|:----: | :----:| :----: |
|1 | VSS Power Supply (GND)| GND|
|2 | VDD Power Supply (+5V)| 5V|
|3 | LCD Driver Power Supply| GND or Potentiometer (see note)|
|4 | RS Register Select| 0 |
|5 | R/W Data Read & Write| 1 |
|6 | E Enable| 2 |
|7 | DB0 Databus 0| 3|
|8 | DB1 Databus 1| 4|
|9 | DB2 Databus 2| 5|
|10 | DB3 Databus 3| 6|
|11 | DB4 Databus 4| 7|
|12 | DB5 Databus 5| 8|
|13 | DB6 Databus 6| 9|
|14 | DB7 Databus 7| 10|
|15/A | Back Light Anode | See Note|
|16/K | Back Light Cathode| GND|

Notes:

1.	Some LCDs will label A and K (backlight pins) as 1 and 2 with VSS starting at 3, others will position A and K connection pins separately from the other pins - check your product datasheet
2.	the LCD Driver power supply can be adjusted with a potentiometer - connecting to GND will probably give the maximum contrast
3.	Back Light LED May be connected straight to 5V in some models or need a series resistor to reduce the voltage - check your product datasheet.

The data pins may be in a single or double row as shown below:

![Rear of two HD44780 LCD devices showing connections.  Note that the smaller device uses a 2x14 connector and separate A and K connections on the other side of the board.](rear-75.jpg)

##phatIO Config
Copy [run.lio](http://www.github.com/phatio/ideas/HD44780/resources/run.lio) to the `io` directory on the phatIO device.  This creates a driver `PHATIO/io/dev/lcd` when text is written to this file, the screen will be cleared and the text written to it.

The LCD Driver chip contains an 80 character buffer that represents the characters on the display.   The following image shows a 4 x 20 LCD when the text `"AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCC DDDDDDDDDDDDDDDDDDDD"` is entered:

![Larged LCD panel a single HD44780 chip can control, note the rather strange mapping from buffer order to lines](large-80.jpg)


To simplify use with smaller screens the number of columns per line can be added in the driver:

	(defconst cols 8)

After this "ABC\nDEF" (with a new line between the letters C and D) would display:

![2x8 LCD panel showing automatic line handling in phatIO](small-60.jpg)


##Further Work

More work is being done on this driver and updates will be published as they are developed, if you manage to use the driver with other LCDs - succesfully or not please comment on the forums

1.	4 bit data bus support
2.	Better initialization - the driver maynot be able to cope with all variants of LCD when they haven't been powered up with the phatIO
3.	Mapping of the customized font to file




