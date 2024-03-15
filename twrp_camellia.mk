#
# Copyright (C) 2023 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from everpal device
$(call inherit-product, device/xiaomi/camellia/device.mk)

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := camellia
PRODUCT_NAME := twrp_camellia
PRODUCT_BRAND := xiaomi
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="camellia-user 12 SP1A.210812.016 V14.0.6.0.TKSIDXM release-keys"

BUILD_FINGERPRINT := Redmi/camellia/camellia:12/SP1A.210812.016/V14.0.6.0.TKSIDXM:user/release-keys
