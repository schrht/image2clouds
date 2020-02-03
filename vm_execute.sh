#!/bin/bash
#
# Description:
#   Execute commands in VM.
#
# History:
#   v1.0  2020-02-03  charles.shih  Init version

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1
[ -z "$SSH_IDENTITY" ] && echo "\$SSH_IDENTITY is essintial but not existing, exit." && exit 1
[ -z "$DOMAIN_IP" ] && echo "\$DOMAIN_IP is essintial but not existing, exit." && exit 1

# Get sudo access
sudo bash -c : || exit 1

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

# Execute in VM
echo "Executing command: $@"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_IDENTITY root@$DOMAIN_IP "$@"
