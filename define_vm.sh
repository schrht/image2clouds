#!/bin/bash
#
# Description:
#   Define the VM from the $IMAGE_FILE.
#
# History:
#   v1.0    2020-01-20  charles.shih  Init version
#   v1.0.1  2020-02-03  charles.shih  Bugfix for IMAGE_LABEL replacement
#   v1.1    2020-02-07  charles.shih  Dynamically determine the emulator

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_LABEL" ] && echo "\$IMAGE_LABEL is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check utilities
sudo virsh --version >/dev/null || exit 1

# Check VM state
state=$(sudo virsh list --all | grep -w "\s$IMAGE_LABEL\s" | awk '{print $3$4}')
echo -e "Name: $IMAGE_LABEL Status: ${state:=undefined}"

if [ "$state" != "undefined" ]; then
	echo "The VM alreay exists, the following commands may help:"
	echo "sudo virsh shutdown $IMAGE_LABEL"
	echo "sudo virsh destroy $IMAGE_LABEL"
	echo "sudo virsh undefine $IMAGE_LABEL"
	exit 1
fi

# Determine emulator
if [ -f /usr/bin/qemu-kvm ]; then
	qemu_kvm_bin=/usr/bin/qemu-kvm
elif [ -f /usr/libexec/qemu-kvm ]; then
	qemu_kvm_bin=/usr/libexec/qemu-kvm
else
	echo "Cannot find the emulator."
	exit 1
fi

# Define the VM
echo -e "\nDefining the VM..."
cp ./source/template.xml $WORKSPACE/template.xml
sed -i "s#{{DOMAIN_NAME}}#$IMAGE_LABEL#" $WORKSPACE/template.xml
sed -i "s#{{IMAGE_FILE}}#$IMAGE_FILE#" $WORKSPACE/template.xml
sed -i "s#{{EMULATOR}}#$qemu_kvm_bin#" $WORKSPACE/template.xml
sudo virsh define $WORKSPACE/template.xml

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_NAME $IMAGE_LABEL
