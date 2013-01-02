title:	Dropbox integration
author:	Andrew Smallbone <andrew@phatio.com>
tags:	dropbox


# Dropbox Integration

The files on phatIO can be exported to dropbox allowing a cheap way of exporting the phatIO functionality to other computers or other devices that [support](https://www.dropbox.com/mobile) Dropbox.

__This has this currently only been tested with phatIO hosted on a Linux and OS X computer and Windows 8__ but should work on Vista/Server 2008/Windows 7.  Please [email](mailto:andrew@phatio.com) if you've managed to export a non NTFS (eg FAT) disk to Dropbox.

Dropbox is not a realtime communication system - latency will be atleast a few seconds (although on a LAN computers won't be communicating via the Dropbox servers - if LAN synching is enabled in Dropbox).  Tests have been done editing the phatIO's pin files on a dropbox capable text editor on an ipad, with the relevant pins going high/low after 2 to 4 seconds.

Similar functionality may be possible with Microsoft SkyDrive and Google Drive.


##Setup on Linux and OS X


Directories should be symbolically linked from the phatIO to your dropbox location, the following would export the entire io directory to Dropbox.

	ln -s $PHATIO/io ~/Dropbox/io
	
alternatively individual directories can be exported:

	ln -s $PHATIO/io/dev ~/Dropbox/io/phatio

Unfortunately Dropbox will overwrite links to individual files (removing the link with a new version of the file) so directories have to be used.

##Setup on Windows

From a Command Prompt (Windows-R cmd) type the following to export the entire phatIO filesystem:

	mklink /D C:\Users\me\Dropbox\io F:\io

where `c:\Users\me\Dropbox` is the location of your Dropbox directory and F: is the location of your phatIO device.

As with Linux file links don't appear to work - directories have to be linked.