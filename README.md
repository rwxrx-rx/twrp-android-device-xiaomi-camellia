# OrangeFox Device Tree for Xiaomi Redmi Note 10 5G (`camellia`)

Official OrangeFox Recovery device tree for the Xiaomi Redmi Note 10 5G (codename: `camellia`, MediaTek MT6833) featuring full touch support in recovery for devices utilizing the Novatek (NVT) touchscreen panel.

---

## The Touchscreen Fix

At recovery boot, the `fb_notifier` never fires on its own, causing the NVT driver to stay stuck in `wakeup-gesture` mode. Consequently, it never emits normal multi-touch events to userspace, leaving the recovery UI completely unresponsive to touch inputs (all touches are erroneously reported via `nvt_ts_wakeup_gesture_report`).

### Mechanism
* The Toggle: Writing `4` then `0` to `/sys/class/graphics/fb0/blank` at boot forces the `SCREEN-ON` notifier to fire.
* The Result: The NVT driver calls `nvt_ts_resume`, exits wakeup-gesture mode, and begins emitting standard multi-touch events so the recovery UI works normally.

---

## Tested Environment

* Device: Redmi Note 10 5G (`M2103K19C`)
* Firmware: MIUI V14.0.6.0.TKSMIXM (Android 13)
* Touch IC: Novatek NT36672C (Tianma panel, FW `0x12`)
* Kernel: `4.14.186-perf-g82b8a4552e62`
* Status: Bootloader unlocked
* Compatibility: Likely works on sibling devices (`camellian`), including the Redmi Note 10T 5G, Redmi Note 11 SE, and POCO M3 Pro 5G.

---

## Build Instructions

### 1. Set Up Workspace and Sync Source

    mkdir OFRP_12.1 && cd OFRP_12.1
    git clone https://gitlab.com/OrangeFox/sync.git
    bash sync/orangefox_sync.sh --branch 12.1 --path "$PWD"

### 2. Clone Device Tree

    git clone -b fox_12.1 https://github.com/cristidclxvi/device_xiaomi_camellia-fox.git \
        device/xiaomi/camellia

### 3. Compile Recovery

    . build/envsetup.sh
    export ALLOW_MISSING_DEPENDENCIES=true
    export FOX_BUILD_DEVICE=camellia
    lunch twrp_camellia-eng
    mka adbd bootimage recoveryimage

* Output Image: `out/target/product/camellia/OrangeFox-*.img` (~64 MB)

---

## Flashing Guide

1. Boot your device into fastboot mode:

    adb reboot bootloader

2. Check the active slot:

    fastboot getvar current-slot

3. Flash the recovery image to the active slot:

    fastboot flash boot_<a|b> OrangeFox-camellia.img

4. Boot directly into recovery:

    fastboot reboot recovery

   > Note: A plain `fastboot reboot` will boot back into MIUI. Recovery only activates via an explicit recovery boot command or hardware key combination.

---

## Verification

If touch input remains unresponsive after flashing, test the manual trigger via ADB shell:

    adb shell 'echo 4 > /sys/class/graphics/fb0/blank; sleep 1; echo 0 > /sys/class/graphics/fb0/blank'

Check the kernel logs to confirm the wake fired successfully:

    adb shell 'dmesg | grep NVT'

* Expected Success Output: `nvt_ts_resume ... end` and `cm_mgr_fb_notifier_callback ... SCREEN ON`.
* Failure Indicator: If touches log `nvt_ts_wakeup_gesture_report ... gesture_id = 1`, the wake sequence failed to trigger.
