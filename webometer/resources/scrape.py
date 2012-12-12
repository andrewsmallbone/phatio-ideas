#! /usr/bin/python


import imaplib
import sys
import json
import urllib2
from xml.dom import minidom
import datetime

# returns the number of unread messages in the imap account
def num_unread_messages(server,port,login,password):
    obj = imaplib.IMAP4_SSL(server, port)
    obj.login(login, password)
    obj.select('Inbox')
    typ, msgnums = obj.search(None,'UnSeen')

    # if string of message ids is not zero length split and count
    if len(msgnums[0]):
        return len(msgnums[0].rsplit(' '))
    else:
        return 0
  
# returns the named json element
def get_json_element(url,element):
	webdata = urllib2.urlopen(url)
	jsondata = json.load(webdata)
	return jsondata[element]

# returns the xml dom from the specified url
def get_xml(url):
	webdata = urllib2.urlopen(url)
	return minidom.parse(webdata)

# returns the temperature of the given citycode in the degrees units 'c' or 'f'
# see http://developer.yahoo.com/weather/ for description
def get_yahoo_temp(citycode,units):
	WEATHER_URL = 'http://weather.yahooapis.com/forecastrss?u={}&w={}'.format(units,citycode)
	WEATHER_NS = 'http://xml.weather.yahoo.com/ns/rss/1.0'
	dom = get_xml(WEATHER_URL)
	condition = dom.getElementsByTagNameNS(WEATHER_NS, 'condition')[0]
	return int(condition.getAttribute('temp'))


if len(sys.argv) == 2:
	file = open(sys.argv[1], 'w')

	timenow = datetime.datetime.now()
    
    # change the following for your details
	unread = num_unread_messages('imap.gmail.com',993,'YOUR_EMAIL_ADDRESS','YOUR_IMAP_PASSWORD')
	followers = get_json_element('http://api.twitter.com/1/users/show.json?screen_name=AndrewSmallbone', 'followers_count')
	temp = get_yahoo_temp(26194557,'c') # helsinki temperature

	file.write('{:02d}{:02d}{:4d}{:4d}{:4d}'.format(timenow.hour, timenow.minute, unread, followers, temp))
	file.close()
else:
	print "usage {} <outputfilename> ".format(sys.argv[0])
	print "  for example {} /mntpoint/io/dev/number ".format(sys.argv[0])
