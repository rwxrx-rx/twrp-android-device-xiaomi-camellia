#!/system/bin/sh
# Wait for /data to be ready
sleep 2

# Create root service directory if it doesn't exist
mkdir -p /data/adb/service.d

# Inject SELinux enforcing script
cat << 'EOF' > /data/adb/service.d/selinux_fix.sh
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

# Set execution permission
chmod 755 /data/adb/service.d/selinux_fix.sh
log -t OrangeFox "SELinux Enforcing script successfully injected to /data!"
