PERL_MAJOR_VER = 5.10

PACKAGES_BROKEN_ON_64BIT_HOST = \

SPECIFIC_PACKAGES = \
	optware-bootstrap kernel-modules \
	binutils gcc libc-dev \

#	$(PACKAGES_REQUIRE_LINUX26) \
#	py-ctypes \
#	redis \
#	$(PERL_PACKAGES) \

# appweb* : download "file not found"
# calc : not defined some standard functions
# classpath : java class not path
# clamav : updated by still error for printing some CFLAGS
# cvs : prev. def of geltline error
# davtools : ext2_super_block member not found
# ecl : won't compile on x86_64 host
# fatresize : deps on parted and PED_ASSIST macro changed in parted 2.4
# gconv-modules : tries copy them from toolchain
# hpijs : conversion const char - should be fixable
# jove : dup def of getline
# minidlna : Makefile not found, new version may fix that
# minihttpd : rename getline in httpd...c
# motion : uses ffmpeg but ffmpeg too new?
# motor : error: conflicting types for 'strndup'
# mpc : compiles but should update to new version. But then requ. new libmpdclient2
# mt-daapd-svn : very old
# [what?] compiles fine now - nail : STACK not found (part of openssl)
# newt : no idea
# ntop : cross compiling ./configure problem
# [ok] pkgconfig : cross compiling ./configure problem
# postfix : unknown machine type
# [ok] procmail : dup getline. appears in a few files, me to lazy to do it right now
# odea : hangs while ./configure - mktimes check
# bacula : won't compile on 64-bit
# bzr : postpone fixing
#
# bacula, erlang, erl-*, imagemagick, inetutils
# [ok] kamailio : -ipk fails
# [ok] libcio : runs pkgconfig-stage, why, only on 64-bit??
# lookat : dup getline
# opensips : some assembler errors
# pcapsipdump : #elif error (change to #else if)
# quagga : -fPIC needed
# [ok] scponly : #elif error
# sendmail : -ipk - sendmail.cf missing
# swi-prolog : configure cross compiling
# textutils : dups getline
# tinyscheme : -fPIC
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	appweb app_web2_4 atftp bitchx bsdgames calc centerim \
	cherokee classpath clamav cvs davtools ecl emacs22 \
	ettercap-ng fatresize fcgi ficy fuppes gconv-modules \
	gnu-smalltalk gift-ares hpijs inferno ipac-ng jove \
	jabberd kismet launchtool lcd4linux ldconfig libbt \
	littlesmalltalk minidlna minihttpd mlocate moblock \
	motion motor mt-daapd-svn newt nget ntop oleo \
	phoneme-advanced postfix ppp puppy \
	bzr subvertpy py-bittorrent py-bluez py-clips py-gdchart2 \
	py-mercurial py-pastescript py-psycopg py-turbogears \
	py-mx-base py-axiom py-epsilon py-mantissa py-nevow qemu \
	py-pygresql \
	qemu-libc-i386 qpopper quickie recode rhtvision sablevm \
	samba2 sendmail setserial splix squeak swi-prolog \
	tesseract-ocr tmsnc tnftpd transcode uemacs uncia \
	util-linux vlc w3m xaw xcursor xterm \

ifeq ($(OPTWARE_TARGET), asustor-x86_64)
BROKEN_PACKAGES += \
	bacula erlang erl-yaws erl-ejabberd imagemagick inetutils \
	libcurl libdvb lookat mini-snmpd mpd mrtg \
	mysql-connector-odbc nrpe opendchub opensips pcapsipdump \
	quagga ser textutils tinyscheme wpa-supplicant \

endif

BIND_CONFIG_ARGS := --disable-epoll

ERLANG_SMP := --enable-smp-support

E2FSPROGS_VERSION := 1.42.8
E2FSPROGS_IPK_VERSION := 5

OPENSSH_CONFIG_OPTS := --without-stackprotect

SQUID_EPOLL := --disable-epoll
