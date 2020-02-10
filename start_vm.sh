#!/bin/bash
#
# Description:
#   Start the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-20  charles.shih  Init version
#   v1.1  2020-02-10  charles.shih  Update VM state checking logic

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check utilities
sudo virsh --version >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh running && exit 0

$(dirname $0)/check_vm_state.sh shutoff
[ "$?" != "0" ] && echo "ERROR: Wrong VM state." && exit 1

# Start VM
echo -e "Starting the VM..."
sudo virsh start $DOMAIN_NAME
