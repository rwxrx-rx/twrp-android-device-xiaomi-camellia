#!/system/bin/sh

# nvt_touch_wake_watch.sh
# Re-kick NVT touchscreen whenever framebuffer wakes.

FB_BLANK=/sys/class/graphics/fb0/blank

# Wait for framebuffer sysfs node.
sleep 2

# Wait until fb0/blank actually exists.
while [ ! -e "$FB_BLANK" ]; do
    sleep 1
done

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
