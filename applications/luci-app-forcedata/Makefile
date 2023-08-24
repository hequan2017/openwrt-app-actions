
include $(TOPDIR)/rules.mk

PKG_VERSION:=1.0.0-20230825
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for forcedata
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +luci-lib-taskd

define Package/luci-app-forcedata/conffiles
/etc/config/forcedata
endef

define Package/luci-app-forcedata/install
    $(INSTALL_DIR) $(1)/usr/libexec/istorec
    $(INSTALL_BIN) ./files/forcedata.sh $(1)/usr/libexec/istorec/forcedata.sh
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
