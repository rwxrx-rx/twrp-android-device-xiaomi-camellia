#!/system/bin/sh

sleep 2

mkdir -p /data/adb/service.d

cat > /data/adb/service.d/selinux_fix.sh <<'EOF'
#!/system/bin/sh

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

resetprop --delete ro.boot.selinux 2>/dev/null
setenforce 1

sleep 3

setenforce 1

log -t SELinux_Fix "SELinux aggressively forced to Enforcing mode."
EOF

chmod 755 /data/adb/service.d/selinux_fix.sh

log -t OrangeFox "SELinux enforcing script injected."
