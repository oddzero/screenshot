include theos/makefiles/common.mk
export ARCHS = armv7

TOOL_NAME = screenshot
screenshot_FILES = main.mm

include $(THEOS_MAKE_PATH)/tool.mk
