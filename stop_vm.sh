#!/bin/bash
#
# Description:
#   Stop the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version
#   v1.1  2020-02-03  charles.shih  Support updating profile with empty values
#   v1.2  2020-02-03  charles.shih  Change the image file's permission back
#   v1.3  2020-02-04  charles.shih  Add checkpoint for $IMAGE_FILE
#   v1.4  2020-02-10  charles.shih  Update VM state checking logic

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check utilities
sudo virsh --version >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh shutoff && exit 0

$(dirname $0)/check_vm_state.sh running
[ "$?" != "0" ] && echo "ERROR: Wrong VM state." && exit 1

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_IP ""

# Stop VM
echo -e "Stopping the VM..."
sudo virsh shutdown $DOMAIN_NAME || exit 1

echo "Waiting the VM to be stopped..."
for i in {1..12}; do
	sleep 5
	$(dirname $0)/check_vm_state.sh shutoff && break
done

$(dirname $0)/check_vm_state.sh shutoff

if [ "$?" = "0" ]; then
	echo "The VM has been shutdown normally."
	echo "Changing image file's permission back to \"$(whoami)\"..."
	sudo chown $(whoami): $IMAGE_FILE || exit 1
	exit 0
else
	echo "Failed to shutdown the VM after 1 minutes."
	echo "Please try to destroy the VM manually:"
	echo "sudo virsh destroy $DOMAIN_NAME"
	echo "sudo chown $(whoami): $IMAGE_FILE"
	exit 1
fi
