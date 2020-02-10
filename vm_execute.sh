#!/bin/bash
#
# Description:
#   Execute commands in VM.
#
# History:
#   v1.0  2020-02-03  charles.shih  Init version
#   v1.1  2020-02-10  charles.shih  Update VM state checking logic

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1
[ -z "$SSH_IDENTITY" ] && echo "\$SSH_IDENTITY is essintial but not existing, exit." && exit 1
[ -z "$DOMAIN_IP" ] && echo "\$DOMAIN_IP is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh running
[ "$?" != "0" ] && echo "ERROR: Wrong VM state." && exit 1

# Execute in VM
echo "Executing command: $@"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_IDENTITY root@$DOMAIN_IP "$@"

exit 0
