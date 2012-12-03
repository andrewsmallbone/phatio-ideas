title:	Dropbox integration
author:	Andrew Smallbone <andrew@phatio.com>
tags:	


# Dropbox Integration

The files on phatIO can be exported to dropbox allowing a cheap way of exporting the phatIO functionality to other computers or other devices that [support](https://www.dropbox.com/mobile) Dropbox.

__Unfortunately this only works if the phatIO is hosted on a Linux and OS X computer__.  Windows does not support sharing files outside of the Dropbox directory.

Dropbox is not a realtime communication system - latency will be atleast a few seconds (although on a LAN computers won't be communicating via the Dropbox servers.  Tests have been done editing the phatIO's pin files on a dropbox capable text editor on an ipad, with the relevant pins going high/low after 2 to 4 seconds.


Similar functionality may be possible with Microsoft SkyDrive and Google Drive.



##Setup


Directories should be symbolically linked from the phatIO to your dropbox location, the following would export the entire io directory to Dropbox.

	ln -s $PHATIO/io ~/Dropbox/io
	
alternatively individual directories can be exported:


	ln -s $PHATIO/io/dev ~/Dropbox/io/phatio

Unfortunately Dropbox will overwrite links to individual files (removing the link with a new version of the file) so directories have to be used.

