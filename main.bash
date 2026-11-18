#!/bin/bash
# This is a part of the UniqueOS Project
# Supported by The QNU Project and NSA of RCL
#set -e
Uniquever="Unique GNU/Linux 1.0-0f1BETA"

yoo() {
        echo -e "\e[1;32m$@\e[0m"
}
BIOS=0
if [ "$1" = "-b" ] && [ ! -d "/sys/firmware/efi" ]; then
        BIOS=1
fi
yoo Welcome to the $Uniquever Installer!
yoo ------------------------------------
yoo "Unique GNU/Linux (c) The QNU Project"
yoo ------------------------------------
yoo
yoo This installer is going to install the $Uniquever on your computer,
yoo it is made by The QNU Project and it is best Linux distro on
yoo the planet. You will be asked some questions so the installation
yoo will complete normally. Also, its very important for you to
yoo "read the documentation (its not very long), because installing"
yoo this operating system is not for newbies in lunix and might be
yoo hard. When youll accept the license, nothing can be done back and
yoo nobody will help you. Installation may be for a long time if you
yoo have some necro computer. On average, it takes for 15 to 30 minutes
yoo to install it.
yoo
if [ "$BIOS" = "1" ]; then
        yoo "BIOS MODE ENABLED"
fi
yoo
read -p "Proceed? (y/n): " lvl1
if [ $lvl1 = "y" ]; then
        echo Ok!
else
        echo I regret nothing.
#       rm -rvf /*
        exit 1
fi
yoo Copyright 2026 The QNU Project
yoo Redistribution and use in source and binary forms, with or without modification,
yoo are permitted provided that the following conditions are met:
yoo
yoo    1. Redistributions of source code must retain the above copyright notice, 
yoo this list of conditions and the following disclaimer.
yoo    2. Redistributions in binary form must reproduce the above copyright notice, 
yoo this list of conditions and the following disclaimer in the documentation and/or 
yoo other materials provided with the distribution.

yoo THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” 
yoo AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
yoo THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
yoo PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
yoo BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
yoo "DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; "
yoo "LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY "
yoo "THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING "
yoo "NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, "
yoo EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
yoo
yoo
read -p "Are you agreeing with the license? (y/n): " lvl1end
if [ $lvl1end = "y" ]; then
        echo Ok!
else
        echo "You'll regret everything."
        exit 1
fi
# Start of the installation /NO WAY BACK........... UniqueOS (c) developer - Envy Envikovich 1998

yoo
yoo
yoo
yoo "(0%) Checking the system..."

if [ "$(id -u)" -ne 0 ]; then
        echo "E003: Not from the root"
        exit 3
fi

yoo "(14%) Checking the system..."

if [ ! -d "/sys/firmware/efi" ] && [ "$BIOS" != "1" ]; then
        echo "E004: BIOS is not supported at this time"
        exit 4
fi
yoo "(28%) Checking the system..."

if curl -s --connect-timeout 3 https://google.com >/dev/null; then
        cat /dev/null
else
        echo "E005: Not connected to the internet/google.com is not available"
        exit 5
fi
if curl -s --connect-timeout 3 https://busybox.net >/dev/null; then
        cat /dev/null
else
        echo "E009: Not connected to the internet/busybox.net is not available"
        exit 9
fi
yoo "(42%) Checking the system..."
command -v curl >/dev/null 2>&1 || { echo "E100: Not installed curl"; exit 1; }
command -v free >/dev/null 2>&1 || { echo "E101: Not installed free"; exit 1; }
command -v df >/dev/null 2>&1 || { echo "E102: Not installed df"; exit 1; }
[ "$BIOS" = "1" ] || command -v mokutil >/dev/null 2>&1 || { echo "E103: Not installed mokutil"; exit 1; }
yoo "(56%) Checking the system..."
locomia=$(free -g | awk '/Mem:/ {print $2}')
if [ "$locomia" -lt 4 ]; then
        echo "E006: Small RAM size"
        exit
fi
yoo "(70%) Checking the system..."
gateway=$(df -m /tmp | awk 'NR==2 {print $4}')
if [ "$gateway" -lt 2048 ]; then
        echo "E007: /tmp < 2 GiB"
        exit 7
fi
yoo "(84%) Checking the system..."
if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
        echo "Secure Boot is enabled."
        read -p "Do you want to continue? (y/n): " secureboot
        if [ "$secureboot" != "y" ]; then
                exit 1
        else
                echo "Be careful! Not tested!!!!!!!!!!"
        fi
fi
yoo "(100%) Checking the system..."
yoo "(0%) Configuring..."
mapfile -t DISK_LINES < <(lsblk -dno NAME,SIZE,TYPE 2>/dev/null | awk '
$3=="disk" {
    name = "/dev/" $1
    size = $2
    
    mount = ""
    cmd = "lsblk -no MOUNTPOINTS /dev/" $1 " 2>/dev/null"
    while ((cmd | getline m) > 0) if (m != "") mount = mount m " "
    close(cmd)
    
    info = " ( " name " ), " size
    if (mount != "") {
        if (mount ~ /\/$/ || mount ~ /\/ /) {
            info = info ", (mounted as " mount ", recommended)"
        } else {
            info = info ", (mounted as " mount ")"
        }
    }
    print info
}')

if [ ${#DISK_LINES[@]} -eq 0 ]; then
    echo "E008: No disks found" >&2
    exit 1
fi

current_index=0
total_items=${#DISK_LINES[@]}
trap 'echo -e "\e[?25h"; exit' INT TERM EXIT
echo -e -n "\e[?25l"
for ((i=0; i<total_items; i++)); do
    if [ $i -eq $current_index ]; then
        echo -e "\e[1;32m> ${DISK_LINES[$i]}\e[0m"
    else
        echo "  ${DISK_LINES[$i]}"
    fi
done

while true; do
    read -rsn3 key
    case "$key" in
        $'\x1b[A')
            old_index=$current_index
            ((current_index--))
            if [ $current_index -lt 0 ]; then current_index=$((total_items - 1)); fi
            ;;
        $'\x1b[B')
            old_index=$current_index
            ((current_index++))
            if [ $current_index -ge $total_items ]; then current_index=0; fi
            ;;
        "")
            break
            ;;
        *)
            continue
            ;;
    esac
    if [ "$old_index" != "$current_index" ]; then
        echo -e -n "\e[${total_items}A"
        
        for ((i=0; i<total_items; i++)); do
            if [ $i -eq $current_index ]; then
                echo -e -n "\e[K\e[1;31m> ${DISK_LINES[$i]}\e[0m\n"
            else
                echo -e -n "\e[K  ${DISK_LINES[$i]}\n"
            fi
        done
    fi
done
echo -e -n "\e[?25h"
SELECTED_TEXT="${DISK_LINES[$current_index]}"
DISK=$(echo "$SELECTED_TEXT" | awk -F '[()]' '{print $2}' | tr -d ' ')
echo "DISK=\"$DISK\""
yoo "(30%) Configuring..."

DISK_NAME=$(basename "$DISK")
FUTURE_LAYOUT="cfdisk.conf"
MOUNTS_CONF="mounts.conf"
> "$FUTURE_LAYOUT"
> "$MOUNTS_CONF"
EFI_FOUND=""
SWAP_FOUND=""
EFI_SIZE=""
SWAP_SIZE=""
START_SECTOR=2048
FIRST_TYPE="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
if [ "$BIOS" = "1" ]; then
    FIRST_TYPE="21686148-6449-6E6F-744E-656564454649"
    EFI_SIZE=2048
fi

for part_path in /sys/class/block/${DISK_NAME}*; do
    [ -e "$part_path" ] || continue
    part_name=$(basename "$part_path")

    [ "$part_name" = "$DISK_NAME" ] && continue

    full_part_path="/dev/$part_name"

    if [ "$BIOS" != "1" ] && lsblk -no FSTYPE "$full_part_path" 2>/dev/null | grep -q -E "vfat|fat"; then
        EFI_FOUND="$full_part_path"
        EFI_SIZE=$(cat "$part_path/size" 2>/dev/null)
        echo "$full_part_path:/boot/efi" >> "$MOUNTS_CONF"
    fi

    if lsblk -no FSTYPE "$full_part_path" 2>/dev/null | grep -q "swap"; then
        SWAP_FOUND="$full_part_path"
        SWAP_SIZE=$(cat "$part_path/size" 2>/dev/null)
        echo "$full_part_path:swap" >> "$MOUNTS_CONF"
    fi
done

if [ -z "$EFI_FOUND" ] && [ "$BIOS" != "1" ]; then
    echo "[WARNING] This disc doesn't contain any EFI partition"
    read -p "Create new EFI partition (512 MiB)? (y/n): " auto_efi

    if [ "$auto_efi" = "y" ]; then
        EFI_SIZE=1048576
        if [[ "$DISK_NAME" =~ "nvme" ]]; then
            echo "${DISK}p1:/boot/efi" >> "$MOUNTS_CONF"
        else
            echo "${DISK}1:/boot/efi" >> "$MOUNTS_CONF"
        fi
    else
        yoo 'E008: Sorry but UniqueOS only supports EFI systems :('
        exit 8
    fi
fi

yoo "(60%) Configuring..."

echo "label: gpt" >> "$FUTURE_LAYOUT"
echo "device: $DISK" >> "$FUTURE_LAYOUT"
echo "unit: sectors" >> "$FUTURE_LAYOUT"
echo "" >> "$FUTURE_LAYOUT"

if [[ "$DISK_NAME" =~ "nvme" ]]; then PART_SUFFIX="p"
fi

echo "${DISK}${PART_SUFFIX}1 : start=$START_SECTOR, size=$EFI_SIZE, type=$FIRST_TYPE" >> "$FUTURE_LAYOUT"
START_SECTOR=$((START_SECTOR + EFI_SIZE))
NEXT_PART_NUM=2

if [ -n "$SWAP_FOUND" ]; then
    echo "${DISK}${PART_SUFFIX}$NEXT_PART_NUM : start=$START_SECTOR, size=$SWAP_SIZE, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F" >> "$FUTURE_LAYOUT"
    sed -i "s|$SWAP_FOUND|${DISK}${PART_SUFFIX}${NEXT_PART_NUM}|g" "$MOUNTS_CONF"
    START_SECTOR=$((START_SECTOR + SWAP_SIZE))
    NEXT_PART_NUM=$((NEXT_PART_NUM + 1))
fi

echo "${DISK}${PART_SUFFIX}$NEXT_PART_NUM : start=$START_SECTOR, size=-, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" >> "$FUTURE_LAYOUT"
echo "${DISK}${PART_SUFFIX}$NEXT_PART_NUM:/" >> "$MOUNTS_CONF"

yoo "(100%) Configuring..."
yoo "(0%) Preparing..." # WIP когда куплю впс
# rootxz download
yoo "(30%) Preparing..."
yoo "(60%) Preparing..."
# md5sum rootxz
yoo "(100%) Preparing..."
yoo "Generating initramfs..."
mkdir initramfs
mkdir -p initramfs/{dev,sys,proc,etc,var,usr,bin,sbin,boot,srv,opt}
mv cfdisk.conf initramfs/
mv mounts.conf initramfs/
#cp /boot/vmlinuz-$(uname -r) initramfs/
mv rootfs.txz initramfs/
wget https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
mv busybox initramfs/bin/
chmod +x initramfs/bin/busybox
mknod initramfs/dev/console c 5 1
cat > initramfs/init <<EOF
#!/bin/busybox sh
busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t devtmpfs none /dev
echo "UniqueOS is installing on your system..."
exec busybox sh
EOF
chmod +x initramfs/init
cd initramfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.gz
cd ..


yoo "(0%) Setting up temp environment..."
mv initramfs.gz /boot/tmpinitrd.gz
yoo "(50%) Setting up temp environment..."
LINUX="vmlinuz-$(uname -r)" # SORRY IF YOU USE JUST vmlinuz OR bzImage :)

# checking for GRUB/SYSTEMD-BOOT
bootloader="unknown"
if command -v kexec >/dev/null 2>&1; then
    bootloader="kexec"
elif [ -d "/boot/loader/entries" ] || [ -f "/boot/loader/loader.conf" ]; then
    bootloader="systemd-boot"
elif [ -f "/boot/grub/grub.cfg" ] || command -v grub-install >/dev/null 2>&1; then
    bootloader="grub"
fi

if [ "$bootloader" = "unknown" ]; then
        echo "E010: Not supportable bootloader"
        exit 10
elif [ "$bootloader" = "kexec" ]; then
        kexec -l /boot/${LINUX} --initrd=/boot/tmpinitrd.gz --command-line="rw console=ttyS0,115200 console=tty0 ignore_loglevel nomodeset" || { echo "E011: kexec failed"; exit 11; }
elif [ "$bootloader" = "grub" ]; then
cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
cat > /boot/grub/grub.cfg <<EOF
set timeout=1
set default=0
set menu_color_normal=white/black
set menu_color_highlight=red/black
menuentry "Installer of UniqueOS ${Uniquever}" {
        linux /boot/${LINUX} root=current rw quiet splash
        initrd /boot/tmpinitrd.gz
}
EOF
elif [ "$bootloader" = "systemd-boot" ]; then
cat > "/boot/loader/entries/uniqueos.conf" <<EOF
title      ${Uniquever}
linux      /${LINUX}
initrd     /tmpinitrd.gz
options    rw quiet splash
EOF

cat > "/boot/loader/loader.conf" <<EOF
default  uniqueos
timeout  1
EOF
fi

yoo "(100%) Setting up temp environment..."
if [ "$bootloader" = "kexec" ]; then
        echo "Rebooting Into Installer:)"
        sleep 5
        sync
        exec kexec -e
fi
echo "Your computer will be restarted in 5 seconds..."
sleep 5
exec /sbin/reboot
# THIS SCRIPT CURRENTLY IS ON VERSION 0707-2026-4
# NOT TESTED ON ANY HARDWARE