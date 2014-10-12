###########################################################
#
# mod-mono
#
###########################################################

#
# MOD_MONO_VERSION, MOD_MONO_SITE and MOD_MONO_SOURCE define
# the upstream location of the source code for the package.
# MOD_MONO_DIR is the directory which is created when the source
# archive is unpacked.
# MOD_MONO_UNZIP is the command used to unzip the source.
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
MOD_MONO_SITE=https://github.com/mono/mod_mono/releases
MOD_MONO_VERSION=3.8
# it's really a GIT archive but I'm to lazy to handle that right now
MOD_MONO_SOURCE=mod_mono-$(MOD_MONO_VERSION).tar.gz
MOD_MONO_DIR=mod_mono-$(MOD_MONO_VERSION)
MOD_MONO_UNZIP=zcat
MOD_MONO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOD_MONO_DESCRIPTION=mod_mono Apache module to host the XSP ASP.NET
MOD_MONO_SECTION=web
MOD_MONO_PRIORITY=optional
MOD_MONO_DEPENDS=apache
MOD_MONO_SUGGESTS=
MOD_MONO_CONFLICTS=

#
# MOD_MONO_IPK_VERSION should be incremented when the ipk changes.
#
MOD_MONO_IPK_VERSION=1

#
# MOD_MONO_CONFFILES should be a list of user-editable files
#MOD_MONO_CONFFILES=/opt/etc/apache2/conf.d/mod_mono.conf
MOD_MONO_CONFFILES=/opt/etc/apache2/mod_mono.conf

#
# MOD_MONO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOD_MONO_PATCHES=$(MOD_MONO_SOURCE_DIR)/cross-compile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOD_MONO_CPPFLAGS=
MOD_MONO_LDFLAGS=

#
# MOD_MONO_BUILD_DIR is the directory in which the build is done.
# MOD_MONO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOD_MONO_IPK_DIR is the directory in which the ipk is built.
# MOD_MONO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOD_MONO_BUILD_DIR=$(BUILD_DIR)/mod-mono
MOD_MONO_SOURCE_DIR=$(SOURCE_DIR)/mod-mono
MOD_MONO_IPK_DIR=$(BUILD_DIR)/mod-mono-$(MOD_MONO_VERSION)-ipk
MOD_MONO_IPK=$(BUILD_DIR)/mod-mono_$(MOD_MONO_VERSION)-$(MOD_MONO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mod-mono-source mod-mono-unpack mod-mono mod-mono-stage mod-mono-ipk mod-mono-clean mod-mono-dirclean mod-mono-check


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOD_MONO_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOD_MONO_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mod-mono-source: $(DL_DIR)/$(MOD_MONO_SOURCE) $(MOD_MONO_PATCHES)

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
$(MOD_MONO_BUILD_DIR)/.configured: $(DL_DIR)/$(MOD_MONO_SOURCE) $(MOD_MONO_PATCHES)
	$(MAKE) apache-stage
	rm -rf $(BUILD_DIR)/$(MOD_MONO_DIR) $(MOD_MONO_BUILD_DIR)
	$(MOD_MONO_UNZIP) $(DL_DIR)/$(MOD_MONO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOD_MONO_PATCHES)" ; \
		then cat $(MOD_MONO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOD_MONO_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(MOD_MONO_DIR) $(MOD_MONO_BUILD_DIR)
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOD_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOD_PYTHON_LDFLAGS) $(PYTHON25_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-apxs=$(STAGING_DIR)/opt/sbin/apxs \
		--with-apr-config=$(STAGING_DIR)/opt/bin/apr-1-config \
		--with-apu-config=$(STAGING_DIR)/opt/bin/apu-1-config \
		--disable-nls \
	)

	touch $(MOD_MONO_BUILD_DIR)/.configured

mod-mono-unpack: $(MOD_MONO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOD_MONO_BUILD_DIR)/.built: $(MOD_MONO_BUILD_DIR)/.configured
	rm -f $@D
	$(MAKE) -C $(@D)
	touch $(@D)

#
# This is the build convenience target.
#
mod-mono: $(MOD_MONO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOD_MONO_BUILD_DIR)/.staged: $(MOD_MONO_BUILD_DIR)/.built
	rm -f $(MOD_MONO_BUILD_DIR)/.staged
	touch $(MOD_MONO_BUILD_DIR)/.staged

mod-mono-stage: $(MOD_MONO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mod-mono
#
$(MOD_MONO_IPK_DIR)/CONTROL/control:
	@install -d $(MOD_MONO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mod-mono" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOD_MONO_PRIORITY)" >>$@
	@echo "Section: $(MOD_MONO_SECTION)" >>$@
	@echo "Version: $(MOD_MONO_VERSION)-$(MOD_MONO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOD_MONO_MAINTAINER)" >>$@
	@echo "Source: $(MOD_MONO_SITE)/$(MOD_MONO_SOURCE)" >>$@
	@echo "Description: $(MOD_MONO_DESCRIPTION)" >>$@
	@echo "Depends: $(MOD_MONO_DEPENDS)" >>$@
	@echo "Suggests: $(MOD_MONO_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOD_MONO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOD_MONO_IPK_DIR)/opt/sbin or $(MOD_MONO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOD_MONO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOD_MONO_IPK_DIR)/opt/etc/mod-mono/...
# Documentation files should be installed in $(MOD_MONO_IPK_DIR)/opt/doc/mod-mono/...
# Daemon startup scripts should be installed in $(MOD_MONO_IPK_DIR)/opt/etc/init.d/S??mod-mono
#
# You may need to patch your application to make it use these locations.
#
$(MOD_MONO_IPK): $(MOD_MONO_BUILD_DIR)/.built
	rm -rf $(MOD_MONO_IPK_DIR) $(BUILD_DIR)/mod-mono_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOD_MONO_BUILD_DIR) \
	    DESTDIR=$(MOD_MONO_IPK_DIR) \
	    top_dir=$(STAGING_DIR)/opt/share/apache2 \
	    LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent" \
	    SH_LIBTOOL="/bin/sh $(STAGING_DIR)/opt/share/apache2/build-1/libtool --silent" \
	    install
	$(STRIP_COMMAND) $(MOD_MONO_IPK_DIR)/opt/libexec/mod_mono.so
	install -d $(MOD_MONO_IPK_DIR)/opt/etc/apache2/conf.d/
	#install -m 644 $(MOD_MONO_SOURCE_DIR)/mod_mono.conf $(MOD_MONO_IPK_DIR)/opt/etc/apache2/conf.d/mod_mono.conf
	$(MAKE) $(MOD_MONO_IPK_DIR)/CONTROL/control
	echo $(MOD_MONO_CONFFILES) | sed -e 's/ /\n/g' > $(MOD_MONO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOD_MONO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mod-mono-ipk: $(MOD_MONO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mod-mono-clean:
	-$(MAKE) -C $(MOD_MONO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mod-mono-dirclean:
	rm -rf $(BUILD_DIR)/$(MOD_MONO_DIR) $(MOD_MONO_BUILD_DIR) $(MOD_MONO_IPK_DIR) $(MOD_MONO_IPK)

#
#
# Some sanity check for the package.
#
mod-mono-check: $(MOD_MONO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOD_MONO_IPK)
