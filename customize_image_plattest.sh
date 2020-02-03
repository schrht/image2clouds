#!/bin/bash
#
# Description:
#   Customize $IMAGE_FILE for platform testing usage.
#
# History:
#   v1.0    2020-02-03  charles.shih  Init version
#   v1.0.1  2020-02-03  charles.shih  Bugfix for image file name

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1

# Check utilities
virt-customize -V >/dev/null || exit 1

# Enlarge the image
echo -e "\nEnlarge the image to 20 GiB..."
fsize=$(ls -l $IMAGE_FILE | awk '{print $5}')
if [ "$fsize" -lt "$((20 * 1024 * 1024 * 1024))" ]; then
	qemu-img create -f qcow2 -o preallocation=metadata $WORKSPACE/newdisk.qcow2 20G || exit 1
	virt-resize --expand /dev/sda1 $IMAGE_FILE $WORKSPACE/newdisk.qcow2 || exit 1
	mv -f $WORKSPACE/newdisk.qcow2 $IMAGE_FILE || exit 1
else
	echo -e "Already enlarged to 20 GiB, skip this operation."
fi

# Place git repos
echo -e "\nGetting git repos..."
if [ ! -e "./platform-test" ]; then
	git clone git://git.engineering.redhat.com/users/darcari/platform-test.git || exit 1
fi
if [ ! -e "./linus" ]; then
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linus || exit 1
fi
read -t 30 -p "Run 'git pull' for repo \"platform-test\" [y/N]? (30s) " answer
[ "$answer" = "y" ] && bash -c "cd ./platform-test && git pull" || echo
read -t 30 -p "Run 'git pull' for repo \"linus\" [y/N]? (30s) " answer
[ "$answer" = "y" ] && bash -c "cd ./linus && git pull" || echo

echo -e "\nPlacing git repos..."
virt-customize -a $IMAGE_FILE --copy-in ./platform-test:/root/
virt-customize -a $IMAGE_FILE --copy-in ./linus:/root/

# Reset SELinux label
echo -e "\nResetting SELinux label..."
virt-customize -a $IMAGE_FILE --selinux-relabel

exit 0
