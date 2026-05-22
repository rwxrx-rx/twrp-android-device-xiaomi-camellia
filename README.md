# device_xiaomi_camellia-fox

OrangeFox device tree for the Xiaomi Redmi Note 10 5G (`camellia`, MediaTek MT6833) with the NVT touchscreen working in recovery.

## The fix

`recovery/root/vendor/etc/init/init.touchwake.rc` registers a oneshot service that writes `4` then `0` to `/sys/class/graphics/fb0/blank` at boot. The toggle fires `fb_notifier_callback(SCREEN ON)`, the NVT driver calls `nvt_ts_resume`, leaves wakeup-gesture mode and starts emitting normal multi-touch events.

Without this, every touch is reported via `nvt_ts_wakeup_gesture_report` and no input events reach the recovery UI.

## Tested

- Redmi Note 10 5G (`M2103K19C`), MIUI `V14.0.6.0.TKSMIXM` (Android 13)
- Touch IC: Novatek `NT36672C`, Tianma panel, FW 0x12
- Kernel: `4.14.186-perf-g82b8a4552e62`
- Bootloader unlocked

Likely also works on the camellian siblings (Redmi Note 10T 5G, Redmi Note 11 SE, POCO M3 Pro 5G).

## Build

```bash
mkdir OFRP_12.1 && cd OFRP_12.1
git clone https://gitlab.com/OrangeFox/sync.git
bash sync/orangefox_sync.sh --branch 12.1 --path "$PWD"

git clone -b fox_12.1 https://github.com/cristidclxvi/device_xiaomi_camellia-fox.git \
    device/xiaomi/camellia

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_BUILD_DEVICE=camellia
lunch twrp_camellia-eng
mka adbd bootimage recoveryimage
```

Output: `out/target/product/camellia/OrangeFox-*.img` (64 MB).

## Flash

```bash
adb reboot bootloader
fastboot getvar current-slot
fastboot flash boot_<a|b> OrangeFox-camellia.img
fastboot reboot recovery
```

Plain `fastboot reboot` still loads MIUI. Recovery only activates on explicit recovery boot.

## Verify

If touch is dead after flashing:

```bash
adb shell 'echo 4 > /sys/class/graphics/fb0/blank; sleep 1; echo 0 > /sys/class/graphics/fb0/blank'
```

Then `dmesg | grep NVT` should show `nvt_ts_resume ... end` and `cm_mgr_fb_notifier_callback ... SCREEN ON`. If touches log `nvt_ts_wakeup_gesture_report ... gesture_id = 1`, the wake did not fire.
