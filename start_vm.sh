#!/bin/bash
#
# Description:
#   Start the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-20  charles.shih  Init version

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check utilities
sudo virsh --version >/dev/null || exit 1

# Check VM state
state=$(sudo virsh list --all | grep -w "\s$DOMAIN_NAME\s" | awk '{print $3$4}')
echo -e "Name: $DOMAIN_NAME Status: ${state:=undefined}"

if [ "$state" != "shutoff" ]; then
	echo "The VM is not in shutoff state, the following commands may help:"
	echo "sudo virsh shutdown $DOMAIN_NAME"
	echo "sudo virsh destroy $DOMAIN_NAME"
	echo "sudo virsh undefine $DOMAIN_NAME"
	exit 1
fi

# Start VM
echo -e "Starting the VM..."
sudo virsh start $DOMAIN_NAME
