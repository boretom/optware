###########################################################
#
# libgdiplus
#
###########################################################

#
# LIBGDIPLUS_VERSION, LIBGDIPLUS_SITE and LIBGDIPLUS_SOURCE define
# the upstream location of the source code for the package.
# LIBGDIPLUS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGDIPLUS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
LIBGDIPLUS_SITE=https://github.com/mono/libgdiplus/archive
LIBGDIPLUS_VERSION=3.8
LIBGDIPLUS_SOURCE=libgdiplus-$(LIBGDIPLUS_VERSION).tar.gz
LIBGDIPLUS_DIR=libgdiplus-$(LIBGDIPLUS_VERSION)
LIBGDIPLUS_UNZIP=zcat
LIBGDIPLUS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGDIPLUS_DESCRIPTION=C-based implementation of the GDI\+ API
LIBGDIPLUS_SECTION=lib
LIBGDIPLUS_PRIORITY=optional
LIBGDIPLUS_DEPENDS=libpng, freetype, fontconfig, cairo

#
# LIBGDIPLUS_IPK_VERSION should be incremented when the ipk changes.
#
LIBGDIPLUS_IPK_VERSION=6

#
# LIBGDIPLUS_LOCALES defines which locales get installed
#
LIBGDIPLUS_LOCALES=

#
# LIBGDIPLUS_CONFFILES should be a list of user-editable files
#LIBGDIPLUS_CONFFILES=/opt/etc/libgdiplus.conf /opt/etc/init.d/SXXlibgdiplus

#
# LIBGDIPLUS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBGDIPLUS_PATCHES=$(LIBGDIPLUS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGDIPLUS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
ifneq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBGDIPLUS_CPPFLAGS+= -DLIBICONV_PLUG
endif
LIBGDIPLUS_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# LIBGDIPLUS_BUILD_DIR is the directory in which the build is done.
# LIBGDIPLUS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGDIPLUS_IPK_DIR is the directory in which the ipk is built.
# LIBGDIPLUS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGDIPLUS_BUILD_DIR=$(BUILD_DIR)/libgdiplus
LIBGDIPLUS_SOURCE_DIR=$(SOURCE_DIR)/libgdiplus
LIBGDIPLUS_IPK_DIR=$(BUILD_DIR)/libgdiplus-$(LIBGDIPLUS_VERSION)-ipk
LIBGDIPLUS_IPK=$(BUILD_DIR)/libgdiplus_$(LIBGDIPLUS_VERSION)-$(LIBGDIPLUS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgdiplus-source libgdiplus-unpack libgdiplus libgdiplus-stage libgdiplus-ipk libgdiplus-clean libgdiplus-dirclean libgdiplus-check

#
# Automatically create a ipkg control file
#
$(LIBGDIPLUS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libgdiplus" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGDIPLUS_PRIORITY)" >>$@
	@echo "Section: $(LIBGDIPLUS_SECTION)" >>$@
	@echo "Version: $(LIBGDIPLUS_VERSION)-$(LIBGDIPLUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGDIPLUS_MAINTAINER)" >>$@
	@echo "Source: $(LIBGDIPLUS_SITE)/$(LIBGDIPLUS_SOURCE)" >>$@
	@echo "Description: $(LIBGDIPLUS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGDIPLUS_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGDIPLUS_SOURCE):
	$(WGET) -P $(@D) $(LIBGDIPLUS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgdiplus-source: $(DL_DIR)/$(LIBGDIPLUS_SOURCE) $(LIBGDIPLUS_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(LIBGDIPLUS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGDIPLUS_SOURCE) $(LIBGDIPLUS_PATCHES) make/libgdiplus.mk
	$(MAKE) libpng-stage freetype-stage fontconfig-stage cairo-stage
	rm -rf $(BUILD_DIR)/$(LIBGDIPLUS_DIR) $(LIBGDIPLUS_BUILD_DIR)
	$(LIBGDIPLUS_UNZIP) $(DL_DIR)/$(LIBGDIPLUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBGDIPLUS_DIR) $(LIBGDIPLUS_BUILD_DIR)
	sed -i -e 's|libpng12-config --|$(STAGING_PREFIX)/bin/&|' \
	       -e 's|libpng-config --|$(STAGING_PREFIX)/bin/&|' $(@D)/configure.ac
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGDIPLUS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGDIPLUS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_LIBPNG12_CONFIG="$(STAGING_PREFIX)/bin/libpng12-config" \
		ac_cv_path_LIBPNG_CONFIG="$(STAGING_PREFIX)/bin/libpng-config" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--without-x \
		--without-libiconv-prefix \
		--with-png=$(STAGING_DIR)/opt \
		--with-jpeg=$(STAGING_DIR)/opt \
		--with-freetype=$(STAGING_DIR)/opt \
		--with-fontconfig=$(STAGING_DIR)/opt \
		--without-xpm \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libgdiplus-unpack: $(LIBGDIPLUS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBGDIPLUS_BUILD_DIR)/.built: $(LIBGDIPLUS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libgdiplus: $(LIBGDIPLUS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGDIPLUS_BUILD_DIR)/.staged: $(LIBGDIPLUS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install \
		DESTDIR=$(STAGING_DIR) transform=''
	rm -rf $(STAGING_LIB_DIR)/libgdiplus.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
	       -e 's| -L/opt/lib||g' $(STAGING_PREFIX)/bin/gdlib-config
	touch $@

libgdiplus-stage: $(LIBGDIPLUS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGDIPLUS_IPK_DIR)/opt/sbin or $(LIBGDIPLUS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGDIPLUS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGDIPLUS_IPK_DIR)/opt/etc/libgdiplus/...
# Documentation files should be installed in $(LIBGDIPLUS_IPK_DIR)/opt/doc/libgdiplus/...
# Daemon startup scripts should be installed in $(LIBGDIPLUS_IPK_DIR)/opt/etc/init.d/S??libgdiplus
#
# You may need to patch your application to make it use these locations.
#
$(LIBGDIPLUS_IPK): $(LIBGDIPLUS_BUILD_DIR)/.built
	rm -rf $(LIBGDIPLUS_IPK_DIR) $(BUILD_DIR)/libgdiplus_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGDIPLUS_BUILD_DIR) DESTDIR=$(LIBGDIPLUS_IPK_DIR) install-strip transform=''
	rm -f $(LIBGDIPLUS_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(LIBGDIPLUS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGDIPLUS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgdiplus-ipk: $(LIBGDIPLUS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgdiplus-clean:
	-$(MAKE) -C $(LIBGDIPLUS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgdiplus-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGDIPLUS_DIR) $(LIBGDIPLUS_BUILD_DIR) $(LIBGDIPLUS_IPK_DIR) $(LIBGDIPLUS_IPK)

#
# Some sanity check for the package.
#
libgdiplus-check: $(LIBGDIPLUS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBGDIPLUS_IPK)
