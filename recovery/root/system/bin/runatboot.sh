#!/system/bin/sh
# NVT touchscreen wake fix
# Author: cristi, 2026-05-22.
#
# At recovery boot, the fb_notifier never fires on its own, so the NVT driver
# stays in wakeup-gesture mode and never emits normal touch events to userspace.
# Toggling /sys/class/graphics/fb0/blank fires the SCREEN-ON notifier, which
# calls nvt_ts_resume and switches the driver to normal touch reporting.
#
# This script handles both the initial cold boot toggle and runs a continuous

# Function to trigger toggle on found framebuffer
trigger_fb_blank() {
    local fb_path="$1"
    if [ -f "$fb_path" ]; then
        echo 4 > "$fb_path"
        sleep 0.2
        echo 0 > "$fb_path"
        log -t touch_wake_fix "Triggered blank/unblank on $fb_path"
    fi
}

# Cold boot initial toggle (searches all existing fb: fb0, fb1, etc.)
sleep 1
for fb in /sys/class/graphics/fb*; do
    if [ -f "$fb/blank" ]; then
        trigger_fb_blank "$fb/blank"
    fi
done
