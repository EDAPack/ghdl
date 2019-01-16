MKFILES_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR=$(abspath $(MKFILES_DIR)/..)
PACKAGES_DIR=$(PROJECT_DIR)/packages
BUILD_DIR=$(PROJECT_DIR)/build
ETC_DIR=$(PROJECT_DIR)/etc

EDAPACK_BUILD_URL=https://github.com/EDAPack/edapack-build

include $(PROJECT_DIR)/etc/package.info
name:=$(name)
version:=$(version)

ifeq (true,$(VERBOSE))
Q=
WGET=wget
UNTARGZ=tar xvzf
else
Q=@
WGET=wget -q
UNTARGZ=tar xzf
endif

uname_o:=$(shell uname -o)

ifeq (Linux,$(uname_o))
platform=linux_x86_64
else
ifeq (GNU/Linux,$(uname_o))
platform=linux_x86_64
else
platform=unknown
endif
endif

# TODO: Package TGZ and URL
GHDL_VERSION=20181129
GHDL_DIR=ghdl-$(GHDL_VERSION)
GHDL_TGZ=$(GHDL_DIR).tar.gz
GHDL_URL=https://github.com/ghdl/ghdl/archive/$(GHDL_VERSION).tar.gz

PREFIX=$(BUILD_DIR)/$(name)/$(name)
PACKAGE=$(BUILD_DIR)/$(name)-$(platform)-$(version).tar.gz

all : $(PACKAGE)

$(PACKAGE) : $(BUILD_DIR)/$(name).d \
		$(PACKAGES_DIR)/install.py \
		$(ETC_DIR)/modulefile \
		$(ETC_DIR)/package.info
	$(Q)mkdir -p $(PREFIX)/etc
	$(Q)cp $(PACKAGES_DIR)/install.py $(PREFIX)/etc
	$(Q)sed -e "s/{{version}}/$(version)/g" \
		-e "s/{{name}}/$(name)/g" \
		$(ETC_DIR)/modulefile  > $(PREFIX)/etc/modulefile
	$(Q)cp $(ETC_DIR)/package.info $(PREFIX)/etc
	$(Q)cd $(PREFIX) ; tar czf $@ *

gnat:=$(shell which gnat)

$(BUILD_DIR)/$(name).d : $(PACKAGES_DIR)/$(GHDL_TGZ)
	$(Q)rm -rf $(BUILD_DIR)/$(name)
	$(Q)mkdir -p $(BUILD_DIR)/$(name)
	$(Q)if test "x$(gnat)" = "x"; then \
		echo "Error: gnat is not present"; \
		exit 1; \
	fi
	$(Q)cd $(BUILD_DIR)/$(name) ; $(UNTARGZ) $(PACKAGES_DIR)/$(GHDL_TGZ)
	$(Q)mkdir -p $(BUILD_DIR)/$(name)/build
	$(Q)cd $(BUILD_DIR)/$(name)/build ; \
		../$(GHDL_DIR)/configure --prefix=$(BUILD_DIR)/$(name)/$(name)
	$(Q)cd $(BUILD_DIR)/$(name)/build ; $(MAKE) 
	$(Q)cd $(BUILD_DIR)/$(name)/build ; $(MAKE) install
	$(Q)touch $@

$(PACKAGES_DIR)/$(GHDL_TGZ) : 
	$(Q)$(WGET) -O $@ $(GHDL_URL) || (rm -f $@ ; exit 1)

$(PACKAGES_DIR)/install.py : 
	$(Q)mkdir -p $(PACKAGES_DIR)
	$(Q)$(WGET) -O $@ $(EDAPACK_BUILD_URL)/raw/master/scripts/install.py

release : $(PACKAGE) $(PACKAGES_DIR)/upload.py
	$(Q)python3 $(PACKAGES_DIR)/upload.py \
		--org EDAPack --repo $(name) \
		--key $(GITHUB_API_TOKEN) --version $(version) $(PACKAGE)

$(PACKAGES_DIR)/upload.py :
	$(Q)mkdir -p $(PACKAGES_DIR)
	$(Q)$(WGET) -O $@ $(EDAPACK_BUILD_URL)/raw/master/scripts/upload.py

clean : 
	$(Q)rm -rf $(BUILD_DIR)

clean-all : 
	$(Q)rm -rf $(BUILD_DIR) $(PACKAGES_DIR)
