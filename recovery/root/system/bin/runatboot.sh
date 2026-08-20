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
# background watcher to re-fire the toggle every time the screen wakes up.

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

# 1. Cold boot initial toggle (searches all existing fb: fb0, fb1, etc.)
sleep 1
for fb in /sys/class/graphics/fb*; do
    if [ -f "$fb/blank" ]; then
        trigger_fb_blank "$fb/blank"
    fi
done

# 2. Continuous background watcher
# WRAPPED WITH ( ) & SO IT RUN IN THE BACKGROUND AND NOT BLOCK THE ORANGEFOX GUI
(
    echo "Starting Multi-Panel Touch Watcher..."

    # Get the initial state from the main framebuffer
    FB_PRIMARY="/sys/class/graphics/fb0/blank"
    if [ ! -f "$FB_PRIMARY" ]; then
        FB_PRIMARY=$(ls /sys/class/graphics/fb*/blank 2>/dev/null | head -n 1)
    fi

    if [ -z "$FB_PRIMARY" ]; then
        log -t touch_wake_fix "Error: No framebuffer blank node found!"
        exit 1
    fi

    prev="$(cat "$FB_PRIMARY" 2>/dev/null)"

    while true; do
        sleep 0.5
        cur="$(cat "$FB_PRIMARY" 2>/dev/null)"
        
        # Detect screen wake up (prev = 1/sleep, cur = 0/awake)
        if [ "$prev" = "1" ] && [ "$cur" = "0" ]; then
            log -t touch_wake_fix "Screen wake detected, re-kicking touch drivers across all panels..."
            
            # Re-execute toggle to ALL available framebuffers on the device
            for fb in /sys/class/graphics/fb*; do
                if [ -f "$fb/blank" ]; then
                    trigger_fb_blank "$fb/blank"
                fi
            done
            
            cur=0
        fi
        prev="$cur"
    done
) & 

# Quickly exit normally so OrangeFox can load the GUI.
exit 0
