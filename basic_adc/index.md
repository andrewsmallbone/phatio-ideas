title:	Basic ADC - Analogue to Digital Conversion
author:	Andrew Smallbone <andrew@phatio.com>
tags:	adc, conditions, pwm, ht16k33

# Basic ADC - Analogue to Digital Conversion

This project shows some example projects using the built in phatIO Analogue to Digital Convertor available on pins: 0, 1, 2, 3, 4, 5, 9, 10, 11, 16, 18, and 19.

## Concepts

As discussed, in the [guide](/guide/basic_io.html), when an ADC pin is in `ADC` mode reading its value will return a value between 0 and 1024 corresponding to the voltage (0 for 0 volts, 1024 for 5 volts, about 200 for 1 volt etc.).

Theoretically writing `ADC` to the mode file for a pin and reading the value file will cause phatIO to read, convert and return the analogue value of the pin:

    # echo "PWM" > $PHATIO/io/mode/0
    # cat $PHATIO/io/pins/0
    549

However, once read the operating system will likely cache the contents of the value file so subsequent reads will return the same value:

    # cat $PHATIO/io/pins/0
    549
    # cat $PHATIO/io/pins/0
    549    

For this reason, ADC is best used scripted from within `run.lio`.

## Setup

A photograph of the setup used is shown below:

![Setup for the ADC demonstration.  On the left a potentiometer is connected to 5V and Ground with the middle wiper terminal connected to pin 16.  On the right pin 0 is connected to 5v with a photoresistor and a (blue) resistor to Ground, forming a voltage dividor.  An LED is connected from pin 10 to ground through a (brown) biasing resistor.](setup-95.jpg)

1.	A [potentiometer](http://en.wikipedia.org/wiki/Potentiometer) was placed between 5V and GND with its arm/output to pin 16.  The Potentiometer is acting as a voltage divider so turning its knob will vary the voltage to pin 16 between 0 and 5V.

2.	A [photoresistor](http://en.wikipedia.org/wiki/Photoresistor) was connected between pin 1 and 5V and a resistor between pin 1 and ground, creating a voltage divider that changes the voltage to pin 1 according to the light intensity on the photoresistor.  The resistor should be choosen to give the good range of voltages as the light changes, you could use a variable resistor to fine tune this.

3.   An LED and biasing resistor was connected from pin 10 to GND.

The code used below is available in the resources directory - listed to the right.


## Scheduled Read

Saving the following to `PHATIO/io/run.lio` will 'type' the analogue values (between 0 and 1023) of pins 1 and 16 every second:

	; define memorable constants for the photo sensor and potentiomter
	(defconst light 1)
	(defconst pot 16)

	; set bot pins to ADC inputs
	(pinmode light ADC)
	(pinmode pot ADC)
	
	(every 1000
	    (keyboard "p: " (getpin pot) ", l: " (getpin light) "\n")
	)


Save an empty file to `run.lio` to stop it typing.  A useful technique for observing output is to open the run.lio file in an editor add the above code and save whilst the cursor is at the end of the file.  The output from phatIO will be _typed_ into the editor window.  When you want to stop - save the file again with this content, because the output is not valid LIO it will stop execution.


## PWM Control
Replacing the schedule with the following (pwm-control.lio) allows us to use the potentiometer as a control knob to adjust the PWM value of the pin connected to the LED:
	
	(defconst l 10) ; define a constant for the output pin
	(pinmode l PWM)
	(every 20
	    (setpin l (/ (getpin pot) 4))
	)


Every 20 milliseconds the ADC input (0..1023) is divided by 4 (`(/ (getpin pot) 4)`) to give a valid PWM value (0..255) for the LED pin.

By using the folowing instead, we increase the intensity of the LED as the light falling on the photo resistor decreases:

	(every 20
		(setpin l (- 255 (/ (getpin light) 4)))
	)


## Conditions

phatIO has builtin [functionality](/guide/lio/conditions/#adc_goes_above) to do something when an analogue input goes above or below a certain value.  The following code (`conditions.lio`) turns on the LED when the photo resistor input goes below 200 and turns it off when the input goes above 800.  Each time a message is 'typed' to the host computer

	(pinmode l OUT)

	(adc_goes_above light 800 200
		(setpin l 0)
		(keyboard "light off ")
	)
	(adc_goes_below light 200 800
		(setpin l 1)
		(keyboard "light on ")
	)

Each condition has a trigger value and (an optional) reset value.  So the first condition won't trigger (execute the code) until `light` pin input goes above 800, it won't trigger again until the pin goes below the reset value and back above the trigger value.  This stops the condition triggering repeatedly as the pin value slowly floats around the trigger value.


## Display

By connecting a 7 segment display to the circuit we can show the value read from an ADC pin, the following adds a 4 character [ht16k33 7 segment display](/ideas/ht16k33/) to the circuit (the display is connected to power and the TWI pins - 12 & 13).  See the [ht16k33 demo](/ideas/ht16k33/) for description of setup and how to initialize the display.  We use a 4 character string variable to hold the numbers to send to the display and a function to map the numbers to 7 segment control bytes (stored in cmap) and send over TWI to the display.


	; 4 character to string to hold current adc value
	(defvar display "    ")

	; convert string in adc variable to segments and send to display
	(defconst cmap 0x3F 0x06 0x5B 0x4F 0x66 0x6D 0x7D 0x07 0x7F 0x6F 0x77)
	(defun update
	 	(twi addr 0x00
			(getvar cmap (- (getvar display 0) '0')) 0x00 ; digit 0
			(getvar cmap (- (getvar display 1) '0')) 0x00 ; digit 1
			0x00 0x00 ; colon
			(getvar cmap (- (getvar display 2) '0')) 0x00 ; digit 2
			(getvar cmap (- (getvar display 3) '0')) 0x00 ; digit 3
		)
	)

Every 200 milliseconds the pot pin is read and converted to a 4 character string using the [fmt function](/guide/lio/keyboard/#fmt) and assigned to the _value_ variable before the display function is called (LIO doesn't have function arguments yet).

	(every 200
		(= display (fmt "%4d" (getpin pot)))
		(update);
	)

The "%4d" [fmt](/guide/lio/keyboard/#fmt) argument will prefix the pin number with spaces.  The map of digits to 7 segment bits (cmap) only maps the digits 0..9 (when the character value has '0' subtracted from it - `(getvar cmap (- (getvar value 0) '0'))`), because phatIO will return 0 for any out of bounds array request a space will be represented with a blank digit on the display.

The video below shows a slight variation - which samples the pin every 20 milliseconds to set the PWM LED and also displays the PWM value on the display every 200ms (code in `adc-display.lio`).

<iframe style="display: block; margin-left: auto; margin-right: auto" width="560" height="315" src="http://www.youtube-nocookie.com/embed/1tn8tkOLtn8" frameborder="0" allowfullscreen></iframe>
