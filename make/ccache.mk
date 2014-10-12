###########################################################
#
# ccache
#
###########################################################

# You must replace "ccache" and "CCACHE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CCACHE_VERSION, CCACHE_SITE and CCACHE_SOURCE define
# the upstream location of the source code for the package.
# CCACHE_DIR is the directory which is created when the source
# archive is unpacked.
# CCACHE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CCACHE_SITE=http://samba.org/ftp/ccache
CCACHE_VERSION=3.1.9
CCACHE_SOURCE=ccache-$(CCACHE_VERSION).tar.bz2
CCACHE_DIR=ccache-$(CCACHE_VERSION)
CCACHE_UNZIP=bzcat
CCACHE_MAINTAINER=Joel Rosdahl http://joel.rosdahl.net
CCACHE_DESCRIPTION=ccache is a compiler cache - it speeds up recompilation 
CCACHE_SECTION=util
CCACHE_PRIORITY=optional
CCACHE_DEPENDS=
CCACHE_CONFLICTS=

#
# CCACHE_IPK_VERSION should be incremented when the ipk changes.
#
CCACHE_IPK_VERSION=1

#
# CCACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CCACHE_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CCACHE_CPPFLAGS=
CCACHE_LDFLAGS=

#
# CCACHE_BUILD_DIR is the directory in which the build is done.
# CCACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CCACHE_IPK_DIR is the directory in which the ipk is built.
# CCACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CCACHE_BUILD_DIR=$(BUILD_DIR)/ccache
CCACHE_SOURCE_DIR=$(SOURCE_DIR)/ccache
CCACHE_IPK_DIR=$(BUILD_DIR)/ccache-$(CCACHE_VERSION)-ipk
CCACHE_IPK=$(BUILD_DIR)/ccache_$(CCACHE_VERSION)-$(CCACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CCACHE_SOURCE):
	$(WGET) -P $(@D) $(CCACHE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ccache-source: $(DL_DIR)/$(CCACHE_SOURCE) $(CCACHE_PATCHES)

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
$(CCACHE_BUILD_DIR)/.configured: $(DL_DIR)/$(CCACHE_SOURCE) $(CCACHE_PATCHES) make/ccache.mk
	rm -rf $(BUILD_DIR)/$(CCACHE_DIR) $(@D)
	$(CCACHE_UNZIP) $(DL_DIR)/$(CCACHE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CCACHE_PATCHES)"; then \
		cat $(CCACHE_PATCHES) | patch -d $(BUILD_DIR)/$(CCACHE_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(CCACHE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CCACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CCACHE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

ccache-unpack: $(CCACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CCACHE_BUILD_DIR)/.built: $(CCACHE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LDSHARED='$(TARGET_CC) -shared'
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ccache: $(CCACHE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ccache
#
$(CCACHE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ccache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CCACHE_PRIORITY)" >>$@
	@echo "Section: $(CCACHE_SECTION)" >>$@
	@echo "Version: $(CCACHE_VERSION)-$(CCACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CCACHE_MAINTAINER)" >>$@
	@echo "Source: $(CCACHE_SITE)/$(CCACHE_SOURCE)" >>$@
	@echo "Description: $(CCACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(CCACHE_DEPENDS)" >>$@
	@echo "Conflicts: $(CCACHE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CCACHE_IPK_DIR)/opt/sbin or $(CCACHE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CCACHE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CCACHE_IPK_DIR)/opt/etc/ccache/...
# Documentation files should be installed in $(CCACHE_IPK_DIR)/opt/doc/ccache/...
# Daemon startup scripts should be installed in $(CCACHE_IPK_DIR)/opt/etc/init.d/S??ccache
#
# You may need to patch your application to make it use these locations.
#
$(CCACHE_IPK): $(CCACHE_BUILD_DIR)/.built
	rm -rf $(CCACHE_IPK_DIR) $(CCACHE_IPK)
	$(MAKE) -C $(CCACHE_BUILD_DIR) install \
		DESTDIR=$(CCACHE_IPK_DIR) 
	$(STRIP_COMMAND) $(CCACHE_IPK_DIR)/opt/bin/*ccache*
#	install -d $(CCACHE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CCACHE_SOURCE_DIR)/rc.ccache $(CCACHE_IPK_DIR)/opt/etc/init.d/SXXccache
	$(MAKE) $(CCACHE_IPK_DIR)/CONTROL/control
#	install -m 644 $(CCACHE_SOURCE_DIR)/postinst $(CCACHE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(CCACHE_SOURCE_DIR)/prerm $(CCACHE_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CCACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ccache-ipk: $(CCACHE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ccache-clean:
	-$(MAKE) -C $(CCACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ccache-dirclean:
	rm -rf $(BUILD_DIR)/$(CCACHE_DIR) $(CCACHE_BUILD_DIR) $(CCACHE_IPK_DIR) $(CCACHE_IPK)

#
# Some sanity check for the package.
#
ccache-check: $(CCACHE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
