###########################################################
#
# patchelf
#
###########################################################

# You must replace "patchelf" and "PATCH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PATCHELF_VERSION, PATCHELF_SITE and PATCHELF_SOURCE define
# the upstream location of the source code for the package.
# PATCHELF_DIR is the directory which is created when the source
# archive is unpacked.
# PATCHELF_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PATCHELF_SITE=http://nixos.org/releases/patchelf/patchelf-0.8
PATCHELF_VERSION=0.8
PATCHELF_SOURCE=patchelf-$(PATCHELF_VERSION).tar.bz2
PATCHELF_DIR=patchelf-$(PATCHELF_VERSION)
PATCHELF_UNZIP=bzcat
PATCHELF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PATCHELF_DESCRIPTION=PatchELF is a small utility to modify the dynamic linker and RPATH of ELF executables
PATCHELF_SECTION=util
PATCHELF_PRIORITY=optional
PATCHELF_DEPENDS=
PATCHELF_CONFLICTS=

#
# PATCHELF_IPK_VERSION should be incremented when the ipk changes.
#
PATCHELF_IPK_VERSION=1

#
# PATCHELF_PATCHES should list any patchelfes, in the the order in
# which they should be applied to the source code.
#
#PATCHELF_PATCHES=$(PATCHELF_SOURCE_DIR)/configure.patchelf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PATCHELF_CPPFLAGS=
PATCHELF_LDFLAGS=

#
# PATCHELF_BUILD_DIR is the directory in which the build is done.
# PATCHELF_SOURCE_DIR is the directory which holds all the
# patchelfes and ipkg control files.
# PATCHELF_IPK_DIR is the directory in which the ipk is built.
# PATCHELF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PATCHELF_BUILD_DIR=$(BUILD_DIR)/patchelf
PATCHELF_SOURCE_DIR=$(SOURCE_DIR)/patchelf
PATCHELF_IPK_DIR=$(BUILD_DIR)/patchelf-$(PATCHELF_VERSION)-ipk
PATCHELF_IPK=$(BUILD_DIR)/patchelf_$(PATCHELF_VERSION)-$(PATCHELF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: patchelf-source patchelf-unpack patchelf patchelf-stage patchelf-ipk patchelf-clean patchelf-dirclean patchelf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PATCHELF_SOURCE):
	$(WGET) -P $(@D) $(PATCHELF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
patchelf-source: $(DL_DIR)/$(PATCHELF_SOURCE) $(PATCHELF_PATCHES)

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
$(PATCHELF_BUILD_DIR)/.configured: $(DL_DIR)/$(PATCHELF_SOURCE) $(PATCHELF_PATCHES) make/patchelf.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PATCHELF_DIR) $(@D)
	$(PATCHELF_UNZIP) $(DL_DIR)/$(PATCHELF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PATCHELF_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PATCHELF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PATCHELF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

patchelf-unpack: $(PATCHELF_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PATCHELF_BUILD_DIR)/.built: $(PATCHELF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
patchelf: $(PATCHELF_BUILD_DIR)/.built

#$(PATCHELF_BUILD_DIR)/.staged: $(PATCHELF_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#patchelf-stage: $(PATCHELF_BUILD_DIR)/.staged
			
#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/patchelf
# 
$(PATCHELF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: patchelf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PATCHELF_PRIORITY)" >>$@
	@echo "Section: $(PATCHELF_SECTION)" >>$@
	@echo "Version: $(PATCHELF_VERSION)-$(PATCHELF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PATCHELF_MAINTAINER)" >>$@
	@echo "Source: $(PATCHELF_SITE)/$(PATCHELF_SOURCE)" >>$@
	@echo "Description: $(PATCHELF_DESCRIPTION)" >>$@
	@echo "Depends: $(PATCHELF_DEPENDS)" >>$@
	@echo "Conflicts: $(PATCHELF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PATCHELF_IPK_DIR)/opt/sbin or $(PATCHELF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PATCHELF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PATCHELF_IPK_DIR)/opt/etc/patchelf/...
# Documentation files should be installed in $(PATCHELF_IPK_DIR)/opt/doc/patchelf/...
# Daemon startup scripts should be installed in $(PATCHELF_IPK_DIR)/opt/etc/init.d/S??patchelf
#
# You may need to patchelf your application to make it use these locations.
#
$(PATCHELF_IPK): $(PATCHELF_BUILD_DIR)/.built
	rm -rf $(PATCHELF_IPK_DIR) $(BUILD_DIR)/patchelf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PATCHELF_BUILD_DIR) prefix=$(PATCHELF_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(PATCHELF_IPK_DIR)/opt/bin/patchelf
	$(MAKE) $(PATCHELF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PATCHELF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
patchelf-ipk: $(PATCHELF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
patchelf-clean:
	-$(MAKE) -C $(PATCHELF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
patchelf-dirclean:
	rm -rf $(BUILD_DIR)/$(PATCHELF_DIR) $(PATCHELF_BUILD_DIR) $(PATCHELF_IPK_DIR) $(PATCHELF_IPK)

#
# Some sanity check for the package.
#
patchelf-check: $(PATCHELF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
