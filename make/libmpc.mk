###########################################################
#
# libmpc
#
###########################################################

#
# LIBMPC_VERSION, LIBMPC_SITE and LIBMPC_SOURCE define
# the upstream location of the source code for the package.
# LIBMPC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMPC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
LIBMPC_SITE=http://www.multiprecision.org/mpc/download
LIBMPC_VERSION=1.0.1
LIBMPC_SOURCE=mpc-$(LIBMPC_VERSION).tar.gz
LIBMPC_DIR=mpc-$(LIBMPC_VERSION)
LIBMPC_UNZIP=zcat
LIBMPC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMPC_DESCRIPTION=GNU C library for the arithmetic of complex numbers
LIBMPC_SECTION=misc
LIBMPC_PRIORITY=optional
LIBMPC_DEPENDS=libgmp libmpfr
LIBMPC_SUGGESTS=
LIBMPC_CONFLICTS=

#
# LIBMPC_IPK_VERSION should be incremented when the ipk changes.
#
LIBMPC_IPK_VERSION=1

#
# LIBMPC_CONFFILES should be a list of user-editable files
#LIBMPC_CONFFILES=/opt/etc/libmpc.conf /opt/etc/init.d/SXXlibmpc

#
# LIBMPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMPC_PATCHES=$(LIBMPC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMPC_CPPFLAGS=
LIBMPC_LDFLAGS=-lgmp -lmpfr

#
# LIBMPC_BUILD_DIR is the directory in which the build is done.
# LIBMPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMPC_IPK_DIR is the directory in which the ipk is built.
# LIBMPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMPC_BUILD_DIR=$(BUILD_DIR)/libmpc
LIBMPC_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/libmpc
LIBMPC_SOURCE_DIR=$(SOURCE_DIR)/libmpc
LIBMPC_IPK_DIR=$(BUILD_DIR)/libmpc-$(LIBMPC_VERSION)-ipk
LIBMPC_IPK=$(BUILD_DIR)/libmpc_$(LIBMPC_VERSION)-$(LIBMPC_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(HOST_MACHINE), x86_64)
LIBMPC_HOST32="--host=i586-pc-linux-gnu"
LIBMPC_M32=-m32
else
LIBMPC_HOST32=
LIBMPC_M32=
endif

.PHONY: libmpc-source libmpc-unpack libmpc libmpc-stage libmpc-ipk libmpc-clean libmpc-dirclean libmpc-check libmpc-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMPC_SOURCE):
	$(WGET) -P $(@D) $(LIBMPC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmpc-source: $(DL_DIR)/$(LIBMPC_SOURCE) $(LIBMPC_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(LIBMPC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMPC_SOURCE) $(LIBMPC_PATCHES) make/libmpc.mk
	$(MAKE) libgmp-stage libmpfr-stage
	rm -rf $(BUILD_DIR)/$(LIBMPC_DIR) $(@D)
	$(LIBMPC_UNZIP) $(DL_DIR)/$(LIBMPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMPC_PATCHES)" ; \
		then cat $(LIBMPC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMPC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMPC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMPC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMPC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmpc-unpack: $(LIBMPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMPC_BUILD_DIR)/.built: $(LIBMPC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmpc: $(LIBMPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMPC_BUILD_DIR)/.staged: $(LIBMPC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	# sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmpc.pc
	touch $@

libmpc-stage: $(LIBMPC_BUILD_DIR)/.staged

$(LIBMPC_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(LIBMPC_SOURCE) make/libmpc.mk
	rm -rf $(HOST_BUILD_DIR)/$(LIBMPC_DIR) $(@D)
	$(LIBMPC_UNZIP) $(DL_DIR)/$(LIBMPC_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(LIBMPC_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(LIBMPC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	    CPPFLAGS="$(LIBMPC_M32)" \
	    ./configure \
		--prefix=/opt $(LIBMPC_HOST32) \
		--disable-nls \
		--disable-shared; \
	    $(MAKE) DESTDIR=$(HOST_STAGING_DIR) install; \
	)
	touch $@

libmpc-host-stage: $(LIBMPC_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmpc
#
$(LIBMPC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPC_PRIORITY)" >>$@
	@echo "Section: $(LIBMPC_SECTION)" >>$@
	@echo "Version: $(LIBMPC_VERSION)-$(LIBMPC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPC_MAINTAINER)" >>$@
	@echo "Source: $(LIBMPC_SITE)/$(LIBMPC_SOURCE)" >>$@
	@echo "Description: $(LIBMPC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMPC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMPC_IPK_DIR)/opt/sbin or $(LIBMPC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMPC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMPC_IPK_DIR)/opt/etc/libmpc/...
# Documentation files should be installed in $(LIBMPC_IPK_DIR)/opt/doc/libmpc/...
# Daemon startup scripts should be installed in $(LIBMPC_IPK_DIR)/opt/etc/init.d/S??libmpc
#
# You may need to patch your application to make it use these locations.
#
$(LIBMPC_IPK): $(LIBMPC_BUILD_DIR)/.built
	rm -rf $(LIBMPC_IPK_DIR) $(BUILD_DIR)/libmpc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMPC_BUILD_DIR) DESTDIR=$(LIBMPC_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(LIBMPC_IPK_DIR)/opt/lib/libmpc.so.*.*.*
#	install -d $(LIBMPC_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMPC_SOURCE_DIR)/libmpc.conf $(LIBMPC_IPK_DIR)/opt/etc/libmpc.conf
#	install -d $(LIBMPC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMPC_SOURCE_DIR)/rc.libmpc $(LIBMPC_IPK_DIR)/opt/etc/init.d/SXXlibmpc
	$(MAKE) $(LIBMPC_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMPC_SOURCE_DIR)/postinst $(LIBMPC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMPC_SOURCE_DIR)/prerm $(LIBMPC_IPK_DIR)/CONTROL/prerm
	echo $(LIBMPC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMPC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmpc-ipk: $(LIBMPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmpc-clean:
	rm -f $(LIBMPC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmpc-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMPC_DIR) $(LIBMPC_BUILD_DIR) $(LIBMPC_IPK_DIR) $(LIBMPC_IPK)

#
# Some sanity check for the package.
#
libmpc-check: $(LIBMPC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
