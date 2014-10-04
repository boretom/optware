###########################################################
#
# expect
#
###########################################################

# You must replace "expect" and "EXPECT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# EXPECT_VERSION, EXPECT_SITE and EXPECT_SOURCE define
# the upstream location of the source code for the package.
# EXPECT_DIR is the directory which is created when the source
# archive is unpacked.
# EXPECT_UNZIP is the command used to unzip the source.
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
EXPECT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/expect
EXPECT_VERSION=5.45
EXPECT_SOURCE=expect$(EXPECT_VERSION).tar.gz
EXPECT_DIR=expect$(EXPECT_VERSION)
EXPECT_UNZIP=zcat
EXPECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EXPECT_DESCRIPTION=The Expect package contains tools for automating interactive applications
EXPECT_SECTION=util
EXPECT_PRIORITY=optional
EXPECT_DEPENDS=tcl
EXPECT_SUGGESTS=
EXPECT_CONFLICTS=

#
# EXPECT_IPK_VERSION should be incremented when the ipk changes.
#
EXPECT_IPK_VERSION=1

#
# EXPECT_CONFFILES should be a list of user-editable files
#EXPECT_CONFFILES=/opt/etc/expect.conf /opt/etc/init.d/S50expect

#
# EXPECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#EXPECT_PATCHES=$(EXPECT_SOURCE_DIR)/configure.patch
EXPECT_PATCHES=$(EXPECT_SOURCE_DIR)/expect-5.43.0-timesys-allow-cross-compile-v2.patch
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXPECT_CPPFLAGS=
EXPECT_LDFLAGS=

#
# EXPECT_BUILD_DIR is the directory in which the build is done.
# EXPECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXPECT_IPK_DIR is the directory in which the ipk is built.
# EXPECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXPECT_BUILD_DIR=$(BUILD_DIR)/expect
EXPECT_SOURCE_DIR=$(SOURCE_DIR)/expect
EXPECT_IPK_DIR=$(BUILD_DIR)/expect-$(EXPECT_VERSION)-ipk
EXPECT_IPK=$(BUILD_DIR)/expect_$(EXPECT_VERSION)-$(EXPECT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EXPECT_SOURCE):
	$(WGET) -P $(@D) $(EXPECT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
expect-source: $(DL_DIR)/$(EXPECT_SOURCE) $(EXPECT_PATCHES)

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
$(EXPECT_BUILD_DIR)/.configured: $(DL_DIR)/$(EXPECT_SOURCE) $(EXPECT_PATCHES) make/expect.mk
	$(MAKE) tcl-stage 
	rm -rf $(BUILD_DIR)/$(EXPECT_DIR) $(@D)
	$(EXPECT_UNZIP) $(DL_DIR)/$(EXPECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EXPECT_PATCHES)" ; \
		then cat $(EXPECT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EXPECT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EXPECT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(EXPECT_DIR) $(@D) ; \
	fi
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXPECT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXPECT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt/ \
		--disable-nls \
		--enable-shared \
		--with-tcl=$(STAGING_LIB_DIR) \
		--with-tclinc=$(STAGING_INCLUDE_DIR) \
	)
	touch $@

expect-unpack: $(EXPECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EXPECT_BUILD_DIR)/.built: $(EXPECT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXPECT_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
expect: $(EXPECT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/expect
#
$(EXPECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: expect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EXPECT_PRIORITY)" >>$@
	@echo "Section: $(EXPECT_SECTION)" >>$@
	@echo "Version: $(EXPECT_VERSION)-$(EXPECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EXPECT_MAINTAINER)" >>$@
	@echo "Source: $(EXPECT_SITE)/$(EXPECT_SOURCE)" >>$@
	@echo "Description: $(EXPECT_DESCRIPTION)" >>$@
	@echo "Depends: $(EXPECT_DEPENDS)" >>$@
	@echo "Suggests: $(EXPECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(EXPECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXPECT_IPK_DIR)/opt/sbin or $(EXPECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXPECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EXPECT_IPK_DIR)/opt/etc/expect/...
# Documentation files should be installed in $(EXPECT_IPK_DIR)/opt/doc/expect/...
# Daemon startup scripts should be installed in $(EXPECT_IPK_DIR)/opt/etc/init.d/S??expect
#
# You may need to patch your application to make it use these locations.
#
$(EXPECT_IPK): $(EXPECT_BUILD_DIR)/.built
	rm -rf $(EXPECT_IPK_DIR) $(BUILD_DIR)/expect_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EXPECT_BUILD_DIR) DESTDIR=$(EXPECT_IPK_DIR)/ install
	$(STRIP_COMMAND) $(EXPECT_IPK_DIR)/opt/bin/expect
	$(MAKE) $(EXPECT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXPECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
expect-ipk: $(EXPECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
expect-clean:
	-$(MAKE) -C $(EXPECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
expect-dirclean:
	rm -rf $(BUILD_DIR)/$(EXPECT_DIR) $(EXPECT_BUILD_DIR) $(EXPECT_IPK_DIR) $(EXPECT_IPK)

#
# Some sanity check for the package.
#
expect-check: $(EXPECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
