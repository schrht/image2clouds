#!/bin/bash
#
# Description:
#   Define the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-20  charles.shih  Init version

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

# Define the VM
echo -e "\nDefining the VM..."
cp ./source/template.xml $WORKSPACE/template.xml
sed -i "s#{DOMAIN_NAME}}#$IMAGE_LABEL#" $WORKSPACE/template.xml
sed -i "s#{{IMAGE_FILE}}#$IMAGE_FILE#" $WORKSPACE/template.xml
sudo virsh define $WORKSPACE/template.xml
