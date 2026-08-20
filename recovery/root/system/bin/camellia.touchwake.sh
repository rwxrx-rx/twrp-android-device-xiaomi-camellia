# !/system/bin/sh
# nvt_touch_wake_watch.sh
# Watches /sys/class/graphics/fb0/blank and re-fires the blank->unblank
# toggle every time the screen wakes (timeout, power button), not just
# at cold boot. Needed because the NVT driver drops back into
# wakeup-gesture mode on every blank, and only the toggle kicks it back
# into normal multi-touch reporting.

FB_BLANK=/sys/class/graphics/fb0/blank

# Small startup delay: this now starts from "on boot" (earlier than before),
# give the framebuffer sysfs node a moment to exist before we start polling it.
sleep 2

prev="$(cat "$FB_BLANK" 2>/dev/null)"

while true; do
    sleep 0.5
    cur="$(cat "$FB_BLANK" 2>/dev/null)"
    if [ "$prev" = "1" ] && [ "$cur" = "0" ]; then
        log -t nvt_touch_wake "screen woke, re-kicking NVT driver"
        echo 4 > "$FB_BLANK"
        sleep 0.2
        echo 0 > "$FB_BLANK"
        cur=0
    fi
    prev="$cur"
done
