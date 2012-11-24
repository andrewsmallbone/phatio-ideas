title:	Using the MCP23017/MCP23S17 IO Expander
author:	Andrew Smallbone <andrew@phatio.com>
tags: twi, spi, ht16k33

[datasheet]: http://ww1.microchip.com/downloads/en/DeviceDoc/21952b.pdf "datasheet"

__This Document is not complete__, the code works and is tested but documentation is not finished and complete, currently it just shows how to map the devices IO ports as output ports mapped to a device file - allowing them to be controlled by writing to a file from the host computer.

# Using the MCP23017/MCP23S17 IO Expander

This guide shows how to communicate with the [MCP23017/MCP23S17 16 Bit IO Expander](http://www.microchip.com/wwwproducts/Devices.aspx?dDocName=en023499) using either SPI (MCP23S17 device) or I2C (MCP23017) an 8 bit version and open drain versions are also available that should work with the same code.

The I2C device is connected to phatIO's two TWI lines (13 and 14) and the SPI device to the 3 SPI pins + 1 select pin.  Upto 8 TWI devices and 8 SPI devices on each Select pin.

##Setup

Photo of the setup is below:

![Setup of I2C (left) and SPI (right) MCP23xS17 IO expander to the phatIO](setup-80.jpg)

__Description TBD__

Follow the pinouts on page 1 of the [datasheet]:

1.	SPI and I2C buses and power connected to phatIO.
2.	Reset pins connected to 5V.
3.  All address pins connected to ground (address of 000)
4.	SPI chip select pin (19) held high to turn off device until configured - __this is important__
5.	IO ports are at the top of the chips 8 bits on each side.
6.	8 LEDs on the left and a ribbon cable are used to test each port.

##Controlling the device

Communication with the device is done through 22 8-bit registers (see table 1-2, on page 5 of the [datasheet]).  These can be accessed one at a time - byte mode,  or in sequential mode where the address is incremented automatically by the device and mutliple bytes are sent or received.

A multi byte sequence to write byte1 to register address, byte2 to register address+1, and so on would be:
	&lt;device address&gt; &lt;register address&gt; &lgt;byte1&gt; &lt;byte2&gt; ...
	 
Both SPI and I2C devices use the same device address byte syntax "0100AAAW":

0100
:	Fixed 

AAA
:	The Chip address corresponding to levels set on pins A0, A1, and A2 on the chips.

W
:	Specifies Read (1) or Write (0) on SPI devices and is always 0 on I2C.


As an example to set registers 0 and 1 to 0x00 (to set IO banks A and B to outputs) we'd send the following:

	0x40 0x00 0x00 0x00

## Initialization

To initialize the device well set registers 0, 1, 12, and 13 to 0, setting both IO banks to outputs and setting the outputs low (in theory this is the default power on condition but its good practice).

I2C initialization is fairly succint:

	(defvar addr 0x40); set a variable for device address
	(twi addr 0x00 0x00 0x00)
	(twi addr 0x12 0x00 0x00)

SPI is a little more involved, set a constant `ss` for the IO pin used as the chips slave select, we configure the SPI bus (because SPI is used for communication with the internal SD card it must be reconfigured before use) - mode 0, MSB first, 250KHz (see the [SPI manual page](/guide/lio/spi/) for details).

The slave select pin must be taken low before the SPI communication and then raised afterwards (note we pull the pin high with a resistor to ensure the chip is deactivated during the startup phase)

	(defconst ss 19)
	(setmode ss OUT 1)
	(spi_conf 0 MSB 6)
	(setpin ss 0)(spi addr 0x00 0x00 0x00)(setpin ss 1)
	(setpin ss 0)(spi addr 0x12 0xFF 0x00)(setpin ss 1)


## Output Driver

Once initialized we can map the 16 IO pins to a device file that can be accessed from the host computer, the following maps the IO pins to `PHATIO/io/dev/twiio` and `PHATIO/io/dev/spiio` for the i2c and SPI devices respectively.  Files are assumed to contain 4 hex characters: "0000" would turn off all bits "FFFF" would turn them on.

	(driver twiio
		(twi addr 0x12 (read_hexbyte 0) (read_hexbyte 2))
	)

	(driver spiio	
		(spi_conf 0 msb 6)
		(setpin ss 0)
	  	  (spi addr 0x12 (read_hexbyte 0) (read_hexbyte 2))
		(setpin ss 1)
	)

The following would create a raw 'binary' device file - the first 2 bytes of which are mapped to the IO pins on the TWI device (first byte GPA, second byte GPB):

	(driver binary
		(twi addr 0x12 (read_byte 0) (read_byte 1))
	)




