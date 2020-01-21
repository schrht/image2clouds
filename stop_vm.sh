#!/bin/bash
#
# Description:
#   Stop the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version

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

if [ "$state" != "running" ]; then
	echo "The VM is not in running state, the following commands may help:"
	echo "sudo virsh shutdown $DOMAIN_NAME"
	echo "sudo virsh destroy $DOMAIN_NAME"
	echo "sudo virsh undefine $DOMAIN_NAME"
	exit 1
fi

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_IP "N/A"

# Stop VM
echo -e "Stopping the VM..."
sudo virsh shutdown $DOMAIN_NAME || exit 1

for i in {1..12}; do
	sleep 5
	state=$(sudo virsh list --all | grep -w "\s$DOMAIN_NAME\s" | awk '{print $3$4}')
	[ "$state" = "shutoff" ] && break
done

if [ "$state" = "shutoff" ]; then
	echo -e "\nThe VM ($DOMAIN_NAME) has been shutdown normally."
	exit 0
else
	echo -e "\nFailed to shutdown the VM after 1 minutes. Please try destroy the VM manually:"
	echo -e "sudo virsh destroy $DOMAIN_NAME"
	exit 1
fi
