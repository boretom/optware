Optware Software Packaging
==========================
This Optware fork adds support for the ASUSTOR NAS and it's based on the [original subversion repository](http://svn.nslu2-linux.org/svnroot/optware/trunk), revision 13119.

What ASUSTOR targets are supported
----------------------------------
- i686  NAS : ASUSTOR AS-20xT/AS-20xTE/AS-30xT
- x86_64 NAS : ASUSTOR AS-60xT

Prerequisite
------------
Compiling is done on Ubuntu 12.04 32-bit and 64-bit. Install the following packages and you will be fine to start with:

````
sudo apt-get install gcc git cvs flex bison make pkg-config rsync gettext libglib2.0-dev \
	autoconf libtool automake automake1.9 sudo patch bzip2 gzip wget sed texinfo subversion
````

How to build a package
----------------------
1. checkout (or fork) this repository 

	````
	git clone https://github.com/boretom/optware.git optware
	````
2. prepare the target, where target can be either `asustor-i686` or `asustor-x86_64`

	````
	$ cd optware
	$ make asustor-i686-target
	$ cd asustor-i686 && make directories toolchain ipkg-utils optware-bootstrap-ipk
	````
3. build a package, e.g. md5deep. See directory optware/make for available packages

	````
	$ make md5deep
	````

Create IPK file for a package
-----------------------------

````
$ make md5deep-ipk
````

Create package index
--------------------

````
$ make index
````
The above command copies all created IPK files to the `packages` subdirectory and builds the three packages index files `Packages`, `Packages.gz` and `Packages.filelist`. The content of the `packages` folder could be copied to the feed directory which which `ipkg` can work.

Links
-----
- [Optware Homepage](http://www.nslu2-linux.org/wiki/Optware)
- [How to add a package to Optware](http://www.nslu2-linux.org/wiki/Optware/AddAPackageToOptware)
- Backup [archive repository](http://ftp.osuosl.org/pub/nslu2/sources/) for the Optware packages sources
- [ASUSTOR Optware packages repositories](http://optware.kupper.org) from the author of this fork (highly untested!)
