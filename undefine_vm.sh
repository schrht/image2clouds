#!/bin/bash
#
# Description:
#   Undefine the VM from the $IMAGE_FILE.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version
#   v1.1  2020-02-03  charles.shih  Support updating profile with empty values
#   v1.2  2020-02-10  charles.shih  Update VM state checking logic

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check utilities
sudo virsh --version >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh undefined && exit 0

$(dirname $0)/check_vm_state.sh shutoff
[ "$?" != "0" ] && echo "ERROR: Wrong VM state." && exit 1

# Undefine VM
echo -e "Undefining the VM..."
sudo virsh undefine $DOMAIN_NAME

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_NAME ""

exit 0
