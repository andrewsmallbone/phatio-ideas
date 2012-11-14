title:	Controlling phatIO from HTML in a web browser
author:	Andrew Smallbone <andrew@phatio.com>
tags:	html


# Controlling phatIO from HTML in a web browser

This is a little experimental and I've found that support for different web browsers and versions varies.

It uses [twFile](http://jquery.tiddlywiki.org/twFile.html) a [jQuery](http://jquery.com/) plugin based on [TiddlyWiki](http://tiddlywiki.com)'s self-saving abilities.

It tries to use the native browse save capabilites and falls back to a Java Applet if none of those work.

Check the source of `index.html`, it currently just creates a list of dropdowns to set the mode of each pin and a text input for the value.

It should be possible to do more complex behaviour - a slider to control PWM intensity, or a bitmap editor writing to an [LED Matrix driver](../ht16k33/) - please contribute.

