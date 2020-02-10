#!/bin/bash
#
# Description:
#   Expand /dev/sda1 in $IMAGE_FILE.
#
# History:
#   v1.0  2020-02-05  charles.shih  Move this logic out from another script.
#   v1.1  2020-02-10  charles.shih  Check VM state before executing

# Parse parameters
if [ -z "$1" ]; then
	echo "Usage: $0 <Size in GiB>"
	exit 1
fi

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1

# Check utilities
qemu-img -V >/dev/null || exit 1
virt-resize -V >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh undefined
if [ "$?" != "0" ]; then
	$(dirname $0)/check_vm_state.sh shutoff
	if [ "$?" != "0" ]; then
		echo "ERROR: The VM must be stopped first."
		exit 1
	fi
fi

# Enlarge the image
size=$1
echo -e "\nEnlarge the image to $size GiB..."
fsize=$(ls -l $IMAGE_FILE | awk '{print $5}')
if [ "$fsize" -lt "$(($size * 1024 * 1024 * 1024))" ]; then
	qemu-img create -f qcow2 -o preallocation=metadata $WORKSPACE/newdisk.qcow2 ${size}G || exit 1
	virt-resize --expand /dev/sda1 $IMAGE_FILE $WORKSPACE/newdisk.qcow2 || exit 1
	mv -f $WORKSPACE/newdisk.qcow2 $IMAGE_FILE || exit 1
else
	echo -e "Already enlarged to $size GiB, skip this operation."
fi

exit 0
