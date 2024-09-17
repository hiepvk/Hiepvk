export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR)
MODULES = jailed
endif

ifndef YOUTUBE_VERSION
YOUTUBE_VERSION = 19.37.2
endif
ifndef YTLITE_VERSION
YTLITE_VERSION = 5.0.2
endif
PACKAGE_VERSION = $(YOUTUBE_VERSION)-$(YTLITE_VERSION)

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = Hiepvk
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

$(TWEAK_NAME)_FILES := $(wildcard Sources/*.xm) $(wildcard Sources/*.x)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Security
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\" -Wno-module-import-in-extern-c
$(TWEAK_NAME)_INJECT_DYLIBS = Tweaks/YTLite/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib $(THEOS_OBJ_DIR)/YouPiP.dylib $(THEOS_OBJ_DIR)/YTVideoOverlay.dylib $(THEOS_OBJ_DIR)/YouMute.dylib $(THEOS_OBJ_DIR)/YouQuality.dylib $(THEOS_OBJ_DIR)/YTUHD.dylib


$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
$(TWEAK_NAME)_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)

include $(THEOS)/makefiles/common.mk
ifneq ($(JAILBROKEN),1)
SUBPROJECTS += Tweaks/YouPiP Tweaks/YTVideoOverlay Tweaks/YouMute Tweaks/YouQuality Tweaks/YTUHD
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
include $(THEOS_MAKE_PATH)/tweak.mk

REMOVE_EXTENSIONS = 0
CODESIGN_IPA = 0

YTLITE_PATH = Tweaks/YTLite
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm.deb
YTLITE_DYLIB = $(YTLITE_PATH)/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/Library/Application\ Support/YTLite.bundle

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		rm -rf $(YTLITE_PATH)/*; \
		$(PRINT_FORMAT_BLUE) "Downloading YTLite"; \
	fi
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
 		curl -s https://raw.githubusercontent.com/hiepvk/ipa/main/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm.deb -o $(YTLITE_DEB); \
 	fi; \
	if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
		tar -xf Tweaks/YTLite/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm.deb -C Tweaks/YTLite; tar -xf Tweaks/YTLite/data.tar* -C Tweaks/YTLite; \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
	fi;
else

endif
