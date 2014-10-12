###########################################################
#
# xsp
#
###########################################################

XPS_SITE=https://github.com/mono/xsp/archive
XPS_VERSION=3.0.11
#XPS_VERSION=git
XPS_SOURCE=xsp-$(XPS_VERSION).tar.gz
XPS_DIR=xsp-$(XPS_VERSION)
XPS_UNZIP=zcat
XPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XPS_DESCRIPTION=Mono ASP.NET hosting server
XPS_SECTION=utilities
XPS_PRIORITY=optional
XPS_DEPENDS=
XPS_CONFLICTS=

#
# XPS_IPK_VERSION should be incremented when the ipk changes.
#
XPS_IPK_VERSION=1

#
# XPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XPS_PATCHES=$(XPS_SOURCE_DIR)/src-man2hlp.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#  When not cross compiling one should use pkg-config
#  PKG_CONFIG_LIBDIR=staging/opt/lib/pkgconfig pkg-config --libs glib-2.0
#

XPS_CPPFLAGS=
XPS_LDFLAGS=

#
# XPS_BUILD_DIR is the directory in which the build is done.
# XPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XPS_IPK_DIR is the directory in which the ipk is built.
# XPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XPS_BUILD_DIR=$(BUILD_DIR)/xsp
XPS_SOURCE_DIR=$(SOURCE_DIR)/xsp
XPS_IPK_DIR=$(BUILD_DIR)/xsp-$(XPS_VERSION)-ipk
XPS_IPK=$(BUILD_DIR)/xsp_$(XPS_VERSION)-$(XPS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xsp-source xsp-unpack xsp xsp-stage xsp-ipk xsp-clean xsp-dirclean xsp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XPS_SOURCE):
	$(WGET) -P $(@D) $(XPS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xsp-source: $(DL_DIR)/$(XPS_SOURCE) $(XPS_PATCHES)

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
$(XPS_BUILD_DIR)/.configured: $(DL_DIR)/$(XPS_SOURCE) $(XPS_PATCHES) make/xsp.mk
	#$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(XPS_DIR) $(XPS_BUILD_DIR)
	$(XPS_UNZIP) $(DL_DIR)/$(XPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XPS_PATCHES)" ; \
		then cat $(XPS_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(XPS_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(XPS_DIR) $(@D)
	#automake --gnu --add-missing --force --copy
	#autoreconf -vif $(@D)
	#(cd $(@D); autoconf)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XPS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XPS_LDFLAGS)" \
		MONO_PATH=$(HOST_STAGING_PREFIX_DIR)/bin \
		PATH=$(HOST_STAGING_PREFIX)/bin:$(PATH) \
		PKG_CONFIG_PATH="$(HOST_STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-docs \
	)
	#$(PATCH_LIBTOOL) $(@D)/libtool
		#--target=$(GNU_TARGET_NAME) \
	touch $@
#		MONO_PATH=$(HOST_STAGING_LIB_DIR)/mono/2.0/ \

xsp-unpack: $(XPS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(XPS_BUILD_DIR)/.built: $(XPS_BUILD_DIR)/.configured
	rm -f $@
#	cd $(@D)/src && $(HOSTCC) -o man2hlp.host man2hlp.c
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
xsp: $(XPS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xsp
#
$(XPS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xsp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XPS_PRIORITY)" >>$@
	@echo "Section: $(XPS_SECTION)" >>$@
	@echo "Version: $(XPS_VERSION)-$(XPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XPS_MAINTAINER)" >>$@
	@echo "Source: $(XPS_SITE)/$(XPS_SOURCE)" >>$@
	@echo "Description: $(XPS_DESCRIPTION)" >>$@
	@echo "Depends: $(XPS_DEPENDS)" >>$@
	@echo "Conflicts: $(XPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XPS_IPK_DIR)/opt/sbin or $(XPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XPS_IPK_DIR)/opt/etc/xsp/...
# Documentation files should be installed in $(XPS_IPK_DIR)/opt/doc/xsp/...
# Daemon startup scripts should be installed in $(XPS_IPK_DIR)/opt/etc/init.d/S??xsp
#
# You may need to patch your application to make it use these locations.
#
$(XPS_IPK): $(XPS_BUILD_DIR)/.built
	rm -rf $(XPS_IPK_DIR) $(XPS_IPK)
	$(MAKE) -C $(XPS_BUILD_DIR) DESTDIR=$(XPS_IPK_DIR) install-strip
	$(MAKE) $(XPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XPS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xsp-ipk: $(XPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xsp-clean:
	-$(MAKE) -C $(XPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xsp-dirclean:
	rm -rf $(BUILD_DIR)/$(XPS_DIR) $(XPS_BUILD_DIR) $(XPS_IPK_DIR) $(XPS_IPK)

#
# Some sanity check for the package.
#
xsp-check: $(XPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
