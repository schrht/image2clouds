#!/bin/bash
#
# Description:
#   Stop the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version
#   v1.1  2020-02-03  charles.shih  Support updating profile with empty values
#   v1.2  2020-02-03  charles.shih  Change the image file's permission back

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
$(dirname $0)/update_profile.sh DOMAIN_IP ""

# Stop VM
echo -e "Stopping the VM..."
sudo virsh shutdown $DOMAIN_NAME || exit 1

echo "Waiting the VM to be stopped..."
for i in {1..12}; do
	sleep 5
	state=$(sudo virsh list --all | grep -w "\s$DOMAIN_NAME\s" | awk '{print $3$4}')
	[ "$state" = "shutoff" ] && break
done

if [ "$state" != "shutoff" ]; then
	echo "Failed to shutdown the VM after 1 minutes."
	echo "Please try to destroy the VM manually:"
	echo "sudo virsh destroy $DOMAIN_NAME"
	echo "sudo chown $(whoami): $IMAGE_FILE"
	exit 1
fi

echo "The VM has been shutdown normally."

# Change back the permission
echo "Changing image file's permission back to \"$(whoami)\"..."
sudo chown $(whoami): $IMAGE_FILE || exit 1

exit 0
