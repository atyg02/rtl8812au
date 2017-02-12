#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8814au
PKG_VERSION:=2017-02-11
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/diederikdehaas/rtl8814AU.git
PKG_SOURCE_VERSION:=39f494a7cd1c50aeb2974399f40966fe250c98f8
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=DL <dl12345@github.com>
PKG_LICENSE:=GPLv2


include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

USER_EXTRA_CFLAGS = -DBACKPORT

ifneq ($(LINUX_KARCH), x86)
USER_EXTRA_CFLAGS += -DCONFIG_MINIMAL_MEMORY_USAGE 
endif

#
# Debugging trace flags
#
USER_EXTRA_CFLAGS += -DCONFIG_DEBUG
USER_EXTRA_CFLAGS += -DCONFIG_DEBUG_RTL871X
USER_EXTRA_CFLAGS += -DCONFIG_DEBUG_CFG80211
USER_EXTRA_CFLAGS += -DCONFIG_PROC_DEBUG
USER_EXTRA_CFLAGS += -DDBG_MEM_ALLOC

MAKE_FEATURES:= \
	CONFIG_POWER_SAVING="n"

NOSTDINC_FLAGS = \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-include backport/backport.h 

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(KERNEL_CROSS)" \
	KSRC="$(LINUX_DIR)" \
	KVER="$(LINUX_VERSION)" \
	M="$(PKG_BUILD_DIR)" \
	MODULE_NAME="8814au" \
	USER_EXTRA_CFLAGS="$(USER_EXTRA_CFLAGS)" \
	NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
	KBUILD_EXTRA_SYMBOLS="${STAGING_DIR}/usr/include/mac80211/Module.symvers" \
	$(MAKE_FEATURES)



define KernelPackage/$(PKG_NAME)
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8814AU wireless USB 802.11ac driver
  DEPENDS:=@USB_SUPPORT +kmod-mac80211 +kmod-usb-core
  FILES:=$(PKG_BUILD_DIR)/8814au.ko
  AUTOLOAD:=$(call AutoProbe,8814au)
endef

define KernelPackage/$(PKG_NAME)/description
 Kernel modules for the Realtek 8814AU and 8821A USB 802.11ac
 wireless USB adapters
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_OPTS)
endef

$(eval $(call KernelPackage,$(PKG_NAME)))
