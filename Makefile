DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkDev
# Ψάχνει αυτόματα για οποιοδήποτε αρχείο .xm ή .x
DarkDev_FILES = $(wildcard *.xm) $(wildcard *.x)
DarkDev_CFLAGS = -fobjc-arc -std=c++11
DarkDev_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
