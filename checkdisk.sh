#!/bin/bash
sudo apt update
sudo apt install hdparm -y
printf "Disk name (eg /dev/sdb1): "
read disk 
sudo umount $disk
set -e
echo ""
echo "Checking Disk $disk"
#sudo umount $disk
workplace="/tmp/diskcheck-$$"
workfile="DT-$$"

echo "Working in $workplace"
sudo mkdir $workplace
sudo mount $disk $workplace/

echo "Write test: Cache On"
hdparm -W1 $disk
dd if=/dev/zero of=$workplace/$workfile bs=1G count=1 oflag=direct    
rm -r $workplace/$workfile
echo "Write test: Cache Off"
hdparm -W0 $disk
dd if=/dev/zero of=$workplace/$workfile bs=1G count=1 oflag=direct    
rm -r $workplace/$workfile

echo "Read test: Cache On"
hdparm -W1 $disk
sudo hdparm -Tt $disk
echo "Read test: Cache Off"
hdparm -W0 $disk
sudo hdparm -Tt $disk

echo "Bad Sectors Check"
badblocks -v $disk > badsectors.txt
if [ -s badsectors.txt ]
then
	echo "Informing e2fsck of bad sectors"
	sudo e2fsck -l badsectors.txt $disk
fi
#end
sudo umount $disk
sudo rm -r $workplace
