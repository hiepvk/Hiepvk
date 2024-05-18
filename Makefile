export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64


export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR)
MODULES = jailed
endif

ifndef YOUTUBE_VERSION
YOUTUBE_VERSION = 19.19.7
endif
PACKAGE_VERSION = $(YOUTUBE_VERSION)

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = Hiepvk
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

$(TWEAK_NAME)_FILES := $(wildcard Sources/*.xm) $(wildcard Sources/*.x)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Security
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"
$(TWEAK_NAME)_INJECT_DYLIBS = $(THEOS_OBJ_DIR)/YouPiP.dylib $(THEOS_OBJ_DIR)/YTVideoOverlay.dylib $(THEOS_OBJ_DIR)/YouMute.dylib $(THEOS_OBJ_DIR)/YouQuality.dylib $(THEOS_OBJ_DIR)/YTUHD.dylib


$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
$(TWEAK_NAME)_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)

include $(THEOS)/makefiles/common.mk
ifneq ($(JAILBROKEN),1)
SUBPROJECTS += Tweaks/YouPiP Tweaks/YTVideoOverlay Tweaks/YouMute Tweaks/YouQuality Tweaks/YTUHD
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
include $(THEOS_MAKE_PATH)/tweak.mk

CODESIGN_IPA = 0



ifneq ($(JAILBROKEN),1)

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support; cp -r Localizations/Hiepvk.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
endif
