#!/bin/bash
#
# Description:
#   Undefine the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version
#   v1.1  2020-02-03  charles.shih  Support updating profile with empty values

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

# Undefine VM
echo -e "Undefining the VM..."
sudo virsh undefine $DOMAIN_NAME

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_NAME ""
