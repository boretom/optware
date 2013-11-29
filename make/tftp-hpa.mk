###########################################################
#
# tftp-hpa
#
###########################################################
#
# $Id: tftp-hpa.mk 10390 2009-06-30 06:17:27Z bzhou $
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
TFTP_HPA_SITE=http://www.kernel.org/pub/software/network/tftp
TFTP_HPA_VERSION=5.0
TFTP_HPA_SOURCE=tftp-hpa-$(TFTP_HPA_VERSION).tar.bz2
TFTP_HPA_DIR=tftp-hpa-$(TFTP_HPA_VERSION)
TFTP_HPA_UNZIP=bzcat
TFTP_HPA_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
TFTP_HPA_DESCRIPTION=A tftp package
TFTP_HPA_SECTION=net
TFTP_HPA_PRIORITY=optional
TFTP_HPA_DEPENDS=xinetd
TFTP_HPA_SUGGESTS=
TFTP_HPA_CONFLICTS=atftp

#
# TFTP_HPA_IPK_VERSION should be incremented when the ipk changes.
#
TFTP_HPA_IPK_VERSION=1

#
# TFTP_HPA_CONFFILES should be a list of user-editable files
TFTP_HPA_CONFFILES=/opt/etc/xinetd.d/tftp

#
# TFTP_HPA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TFTP_HPA_PATCHES=$(TFTP_HPA_SOURCE_DIR)/xinetd-conf.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TFTP_HPA_CPPFLAGS=
TFTP_HPA_LDFLAGS=

ifeq (, $(filter cs08q1armel i686g25 slugos5be slugos5le ts509, $(OPTWARE_TARGET)))
TFTP_HPA_CONFIGURE_OPTS=--without-ipv6
endif

#
# TFTP_HPA_BUILD_DIR is the directory in which the build is done.
# TFTP_HPA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TFTP_HPA_IPK_DIR is the directory in which the ipk is built.
# TFTP_HPA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TFTP_HPA_BUILD_DIR=$(BUILD_DIR)/tftp-hpa
TFTP_HPA_SOURCE_DIR=$(SOURCE_DIR)/tftp-hpa
TFTP_HPA_IPK_DIR=$(BUILD_DIR)/tftp-hpa-$(TFTP_HPA_VERSION)-ipk
TFTP_HPA_IPK=$(BUILD_DIR)/tftp-hpa_$(TFTP_HPA_VERSION)-$(TFTP_HPA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TFTP_HPA_SOURCE):
	$(WGET) -P $(@D) $(TFTP_HPA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tftp-hpa-source: $(DL_DIR)/$(TFTP_HPA_SOURCE) $(TFTP_HPA_PATCHES)

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
$(TFTP_HPA_BUILD_DIR)/.configured: $(DL_DIR)/$(TFTP_HPA_SOURCE) $(TFTP_HPA_PATCHES) make/tftp-hpa.mk
#	$(MAKE)  tftp_hpa-stage tftp-hpa-stage
	rm -rf $(BUILD_DIR)/$(TFTP_HPA_DIR) $(@D)
	$(TFTP_HPA_UNZIP) $(DL_DIR)/$(TFTP_HPA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TFTP_HPA_PATCHES) | patch -d $(BUILD_DIR)/$(TFTP_HPA_DIR) -p1
	mv $(BUILD_DIR)/$(TFTP_HPA_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(TFTP_HPA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TFTP_HPA_LDFLAGS)" \
		./configure \
		--without-readline \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		$(TFTP_HPA_CONFIGURE_OPTS) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

tftp-hpa-unpack: $(TFTP_HPA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TFTP_HPA_BUILD_DIR)/.built: $(TFTP_HPA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tftp-hpa: $(TFTP_HPA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(TFTP_HPA_BUILD_DIR)/.staged: $(TFTP_HPA_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) INSTALLROOT=$(STAGING_DIR) install
#	touch $@
#
#tftp-hpa-stage: $(TFTP_HPA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tftp-hpa
#
$(TFTP_HPA_IPK_DIR)/CONTROL/control:
	@install -d $(TFTP_HPA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tftp-hpa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TFTP_HPA_PRIORITY)" >>$@
	@echo "Section: $(TFTP_HPA_SECTION)" >>$@
	@echo "Version: $(TFTP_HPA_VERSION)-$(TFTP_HPA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TFTP_HPA_MAINTAINER)" >>$@
	@echo "Source: $(TFTP_HPA_SITE)/$(TFTP_HPA_SOURCE)" >>$@
	@echo "Description: $(TFTP_HPA_DESCRIPTION)" >>$@
	@echo "Depends: $(TFTP_HPA_DEPENDS)" >>$@
	@echo "Suggests: $(TFTP_HPA_SUGGESTS)" >>$@
	@echo "Conflicts: $(TFTP_HPA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(TFTP_HPA_IPK): $(TFTP_HPA_BUILD_DIR)/.built
	rm -rf $(TFTP_HPA_IPK_DIR) $(BUILD_DIR)/tftp-hpa_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TFTP_HPA_BUILD_DIR) INSTALLROOT=$(TFTP_HPA_IPK_DIR) install
	mv $(TFTP_HPA_IPK_DIR)/man $(TFTP_HPA_IPK_DIR)/opt/
	install -d $(TFTP_HPA_IPK_DIR)/opt/etc/xinetd.d
	install -d $(TFTP_HPA_IPK_DIR)/opt/tftpboot
	install -m 644 $(TFTP_HPA_BUILD_DIR)/tftp-xinetd $(TFTP_HPA_IPK_DIR)/opt/etc/xinetd.d/tftp
	$(MAKE) $(TFTP_HPA_IPK_DIR)/CONTROL/control
	install -m 755 $(TFTP_HPA_SOURCE_DIR)/postinst $(TFTP_HPA_IPK_DIR)/CONTROL/postinst
	$(STRIP_COMMAND) $(TFTP_HPA_IPK_DIR)/opt/sbin/* $(TFTP_HPA_IPK_DIR)/opt/bin/*
	echo $(TFTP_HPA_CONFFILES) | sed -e 's/ /\n/g' > $(TFTP_HPA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TFTP_HPA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tftp-hpa-ipk: $(TFTP_HPA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tftp-hpa-clean:
	-$(MAKE) -C $(TFTP_HPA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tftp-hpa-dirclean:
	rm -rf $(BUILD_DIR)/$(TFTP_HPA_DIR) $(TFTP_HPA_BUILD_DIR) $(TFTP_HPA_IPK_DIR) $(TFTP_HPA_IPK)

#
# Some sanity check for the package.
#
tftp-hpa-check: $(TFTP_HPA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
