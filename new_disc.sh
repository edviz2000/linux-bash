#!/bin/bash

# Simple LVM Disk Setup Script
# Use with caution - will format and modify disks!

set -e  # Exit on any error

echo "=== LVM Disk Setup Script ==="

# Ask user for details
echo -n "Enter the device name (e.g., /dev/sdb): "
read DEVICE

if [ ! -b "$DEVICE" ]; then
  echo "Error: $DEVICE does not exist or is not a block device."
  exit 1
fi

echo -n "Enter partition number to create (e.g., 1): "
read PART_NUM
PARTITION="${DEVICE}${PART_NUM}"

echo -n "Enter Volume Group name (e.g., vg_data): "
read VG_NAME

echo -n "Enter Logical Volume name (e.g., lv_data): "
read LV_NAME

echo -n "Enter Logical Volume size (e.g., 20G): "
read LV_SIZE

echo -n "Enter mount point (e.g., /mnt/data): "
read MOUNT_POINT

# Partition the disk
echo "Creating partition..."
echo -e "n\n\n\n\n\nt\n8e\nw" | fdisk "$DEVICE"

# Create Physical Volume
pvcreate "$PARTITION"

# Create Volume Group
vgcreate "$VG_NAME" "$PARTITION"

# Create Logical Volume
lvcreate -L "$LV_SIZE" -n "$LV_NAME" "$VG_NAME"

# Create Filesystem
mkfs.ext4 "/dev/$VG_NAME/$LV_NAME"

# Create Mount Point Directory
mkdir -p "$MOUNT_POINT"

# Mount the Logical Volume
mount "/dev/$VG_NAME/$LV_NAME" "$MOUNT_POINT"

# Backup /etc/fstab
cp /etc/fstab /etc/fstab.bak

# Add to /etc/fstab
echo "/dev/$VG_NAME/$LV_NAME  $MOUNT_POINT  ext4  defaults  0  2" >> /etc/fstab

# Test the new fstab entry
mount -a

echo "=== Setup Complete! ==="
echo "Volume mounted at $MOUNT_POINT and persistent across reboots."