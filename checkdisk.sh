#!/bin/bash
echo "run as root"
sleep 1
 apt update
 apt install hdparm pm-utils -y
printf "Disk name (eg /dev/sdb1): "
read disk 
 umount $disk
set -e
echo ""
echo "Checking Disk $disk"
# umount $disk
workplace="/tmp/diskcheck-$$"
workfile="DT-$$"

echo "Working in $workplace"
 mkdir $workplace
 mount $disk -o defaults,noatime $workplace/
echo "Test: Cache On"
hdparm -W1 $disk
 hdparm -Tt $disk

echo "Test: Cache Off"
sudo /sbin/sysctl -w vm.drop_caches=3
hdparm -W0 $disk
 hdparm -Tt $disk

echo "Bad Sectors Check"
badblocks -v $disk > badsectors.txt
if [ -s badsectors.txt ]
then
        echo "Informing e2fsck of bad sectors"
         e2fsck -l badsectors.txt $disk
fi
#end
 umount $disk
 rm -r /tmp/diskcheck-*
