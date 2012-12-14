title:	Webometer
author:	Andrew Smallbone <andrew@phatio.com>
tags: web, ht16k33, 7 segment, python


# Webometer

This _idea_  illustrates using a simple 4 digit 7 segment display to show some numbers written to a phatIO file from the host computer:

1.	The number of unread mails in an email inbox (obtained from an IMAP mail account)
2.	The number of twitter followers a user has (parsed from the json response from the Twitter API)
3.	The current temperature of a city from yahoo weather (obtained from XML returned from  the Yahoo API)
4.	The current time

![Webometer housed in a (cardboard) box - uses an Adafruit [ht16k33](/ideas/ht16k33/) LED display.](twihoused-50.jpg)

The host computer updates the data every minute and writes it to a file on the phatIO.  Every 3 seconds phatIO cycles through each value, lighting an LED to indicate which is being displayed.  Both a simple [multiplexed 7 segment  LED](/ideas/7segment/) and (Adafruit) [TWI based display](/ideas/ht16k33) displays were developed, as shown in the video below:

<iframe width="560" height="315" style="display: block; margin-left: auto; margin-right: auto" src="http://www.youtube-nocookie.com/embed/h-ydurPGKIY" frameborder="0" allowfullscreen></iframe>


Python was used to get the data from the internet, because:

1.	A version ships with most LInux installations and Mac OS X and comes as an easy to install package for windows
2.	Has built in libraries for HTTP, JSON, XML etc. so doesn't need additional packages installed


The concepts here could be repeated with any language or with other data 'scraped' from the internet or host computer.


## Hardware

The circuit for the raw seven segment display multiplexed [previously](/ideas/7segment/) was used to test the idea.  The display used has built in 'email', 'sound' and 'BYPASS' icons which were lit when displaying the unread emails, twitter count, and temperature respectively.  When the time was being displayed the colon but no other LEDs were lit, these were connected to phatIO pins 16, 17, 18, & 19 and a resistor to ground (via the green connector wires shown below)

![Breadboard circuit of Webometer using a 'raw' 7 segment display multiplexed by the phatIO.  See [further details](/ideas/7segment/).](circuit-75.jpg)

The TWI/I2C ht16k33 LED display used [previously](/ideas/ht16k33/#segmentdisplays) with 3 LEDs connected to pins 17, 18, and 19 to indicate the 'mode' (shown above).

##phatIO Code

There's a number of different approaches for communication between the host computer and phatIO:

1.	A file containing the current displayed value, which the host computer rewrites to change the display and setting the 'mode' LEDs directly via the pin files
2.	Separate files for each of the values which the phatIO cycles through
3.	Single file with all data which the phatIO cycles through

Becuase we want to cycle through the data more frequently than we want to update it (a different piece of data is shown every 3 seconds in this example with the data being updated every minute on the host computer) the latter approach was used.

The python on the host computer writes a 16 character string to file `io/dev/webometer` in format:

	"AAAABBBBCCCCDDDD"

where "AAAA" is the current time, "BBBB" is the number of unread emails etc.   When the data is written to phatIO it converts the text to bytes for the 7 segment display and saves it in a 16 byte array.

See the ideas pages for [ht16k33](/ideas/ht18k33/) and [7 segment](/ideas/7segment/) for specific details on how phatIO interfaces with the devices.  The 2 phatIO config files (one for ht16k33 and one for 'raw' 7segment displahys) and python code are in the sidebar - copy `io/run.lio` on the phatIO device.


Every 3 seconds the phatIO simply increments the current mode, displays the relevant data on the display and lights an appropriate LED.  The only difference between the raw and 7segment versions is that the phatIO directly lights the colon LED when the time is displayed in the raw 7 segment version and sends 0xFF (rather than 0x00) as the 3rd digit in the ht16k33 version.


## Python

The python code is in a single file scrape.py, it calls functions to get the imap, twitter, and yahoo data and then writes directly to the phatIO file (passed as an argument to the script):

	file.write('{:02d}{:02d}{:4d}{:4d}{:4d}'
			.format(timenow.hour, timenow.minute, unread, followers, temp))

The "{:4d}" are used to create exactly 4 characters for each piece of data - spaces are used as prefixes if the number is too short.

## IMAP unread messages

The python imap library is used to get the number of unread messages from the specified server and user/password combination (fill in username and password in the script). 

## Twitter/JSON data

The old (deprecated) Twitter API version 1 is used, although this will stop working at some point, it still easier to use until as it doesn't require authentication or registration.  The python script uses a 3 line function to get an element from the JSON returned from the request URL.

	def get_json_element(url,element):
		webdata = urllib2.urlopen(url)
		jsondata = json.load(webdata)
		return jsondata[element]

	followers = get_json_element(URL, 'followers_count')

The above function can be used to extract fields from any JSON data on the web.  Check the [Twitter documentation](https://dev.twitter.com/docs/api) for other information that it provides.  Note that this version of the webometer is limited to displaying upto 9999 - for larger numbers, the value will need to be divided - or a larger/multiple displays used.


## Yahoo Weather

Yahoo provides an XML [API](http://developer.yahoo.com/weather/) that provides several pieces of information for most places around the world.  The data is a little harder to extract from the XML - specific code is required, but a similar approach can be used to parse XML from other sources.

Search for a location on [weather.yahoo.com](http://weather.yahoo.com/) and use the number in the URL as the citycode in the function call, the second argument is 'c' or 'f' to display Centigrade or Fahrenheit.

	def get_yahoo_temp(citycode,units):
		WEATHER_URL = 'http://weather.yahooapis.com/forecastrss?u={}&w={}'
						.format(units,citycode)
		WEATHER_NS = 'http://xml.weather.yahoo.com/ns/rss/1.0'
		dom = get_xml(WEATHER_URL)
		condition = dom.getElementsByTagNameNS(WEATHER_NS, 'condition')[0]
		return int(condition.getAttribute('temp'))

	temp = get_yahoo_temp(26194557,'c') # helsinki temperature in centigrade


## Running on Linux/Mac OS X

On a linux based system crontab can be used to execute the python script every minute:

	* * * * * (/usr/local/bin/scrape.py /mnt/PHATIO/io/dev/webometer)

The python is designed to _throw_ exceptions/errors out of the program without writing to the phatIO file.  So these will be logged by the cron implementation, alternatively pipe the output to a log file:

	* * * * * (/usr/local/bin/scrape.py /mnt/PHATIO/io/dev/webometer \
		>> /tmp/scrape.log 2>&1 )



## Running on Windows

[ActivePython](http://www.activestate.com/activepython/downloads) was used for this demonstration.  Download is free and installation is simple.

After installation executing the following in a DOS prompt will run the script:

	python scrape.py E:\io\dev\webometer

The windows Scheduler can be used to run the program every minute (Accessories->System Tools->Scheduled Tasks).  Use the following as the `Run` command (changing filepaths to suit).  Pythonw (rather than python) will run the script in the background.

	C:\Python27\pythonw.exe C:\phatio\scrape.py E:\io\dev\webometer


Create the schedule to run once a day and then click the Advanced button in Schedule to choose to run every minute.










