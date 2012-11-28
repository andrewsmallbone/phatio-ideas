title:	Simple Keyboard hacks
author:	Andrew Smallbone <andrew@phatio.com>
tags: keyboard conditions

__This Document is not complete__, the code works and is tested but documentation is far from complete.

This page is intended as a list of example ideas for using the keyboard simulation in phatIO.

# Simple Keyboard Hacks

##Setup

Photo of the setup is below:

	
![Push button switch connected to pin 1 and foot switch to pin 0 with other terminals to ground.](setup-100.jpg)


I've just wired up two push button switches to pins 0 and 1, with the other terminal to ground.  One is a micro switch fitted on the bread board, the other is a foot switch - useful for putting under the desk to use when working at your computer.

The pins are set in [HIGH](/guide/basic_io/) mode - digital inputs pulled high (to 5V) via an internal resistor.  

	(pinmode 0 HIGH)
	(pinmode 1 HIGH)


When the buttons are pressed the pins will be connected to 0V, which we can capture using a [condition](/guilde/lio/conditions/), the following would type "hello " everytime the button connected to pin 0 is pressed:

	(pin_goes_low 0 (keyboard "hello "))

The following ideas don't necessarily have to be triggered from a switch - it could be an [analog condition](../ideas/basic_adc/) or some other event.

Add the following code to run.lio or copy the version in the resources sidebar on the right of this page to your phatIO and uncomment the required action.


See the [keyboard](/guide/lio/keyboard) section of the guide for how to simulate Control and Function keys.

## Typing Speed

To Be Written.


## __I Love You__ Gmail reply

Inspired by [SAGA: Semi-Automatic Gmail Assistant](http://milwaukeemakerspace.org/2012/11/automatic-gmail-assistant/).  Pressing the button will reply to the current message you're reading in the [gmail web page](http://mail.google.com/) with "I love you":

	(pin_goes_low 0 (keyboard "r I Love you\t\n"))
	
Perhaps a more useful is a simple "j" to go to next mail - useful if triggered by a foot switch when drinking coffee/eating breakfast:

	(pin_goes_low 0 (keyboard "j"))

A sequence of [gmail shortcuts](http://support.google.com/mail/bin/answer.py?hl=en&answer=6594) can be added together to script and action.

## Launch Windows Application and Documents

All the existing Windows shortcuts can be scripted from phatIO, applications and documents can have keyboard shortcuts assigned:
 
By creating a shortcut to an application or document (right mouse button menu), then opening the shortcuts properties (right mouse button menu) a Keyboard shortcut can be assigned that will open the application or document when typed:

	(pin_goes_low 0 (keyboard "%{LeftControl+LeftAlt+J}"))

The shortcut has to be on the desktop or within the Start Menu (`C:\Documents and Settings\%USER%\Start Menu`).

## OS X hacks
Check the Keyboard System Preferences panel for keyboard shortcuts available for your entire mac or specific applications - you can automate just about anything, the following zooms in when one button pressed and zooms out on the other.

	(pin_goes_low 0 (keyboard "%{LeftAlt+LeftGUI+=}"))
	(pin_goes_low 1 (keyboard "%{LeftAlt+LeftGUI+-}"))



## OS X LaunchBar hacks

LaunchBar is a Mac application launcher from keyboard shortcuts - if you have it its possible to send it keystrokes by prefixing with "%{LeftGUI+ }" (Command+Space), for example to send a tweet (adding an extra newline at the end would send the tweet):

	(pin_goes_low 0 (keyboard "%{LeftGUI+ }twitter This is an automated tweet \n"))
	
Or to phone someone with skype:

	(pin_goes_low 0 (keyboard "%{LeftGUI+ }twitter This is an automated tweet \n"))



