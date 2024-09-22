FINALPACKAGE=1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += CameraControlEnabler_SpringBoard

include $(THEOS_MAKE_PATH)/aggregate.mk
