#!/bin/bash
#
# Description:
#   Get the information of the VM.
#
# History:
#   v1.0  2020-01-21  charles.shih  Init version

# Load profile and verify the veribles
source ./profile
[ -z "$DOMAIN_NAME" ] && echo "\$DOMAIN_NAME is essintial but not existing, exit." && exit 1
[ -z "$SSH_IDENTITY" ] && echo "\$SSH_IDENTITY is essintial but not existing, exit." && exit 1

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

# Get VM's IP ADDR
echo -e "Get VM's MAC ADDR..."
vm_mac=$(sudo virsh dumpxml $DOMAIN_NAME | grep "mac address=" | awk -F "'" '{print $2}')
for i in {1..5}; do
	echo -e "Get VM's IP ADDR, attempting $i..."
	sleep 10
	vm_ip=$(arp | grep $vm_mac | awk '{print $1}')
	[ ! -z "$vm_ip" ] && echo -e "\nIP ADDR = $vm_ip" && break
done
[ -z "$vm_ip" ] && echo -e "\nTimed out: failed to get VM's IP ADDR, exit." && exit 1

vm_ssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_IDENTITY root@$vm_ip"

# Show VM information
echo -e "\nSSH to the VM:\n$vm_ssh"

# Update profile
$(dirname $0)/update_profile.sh DOMAIN_IP $vm_ip

exit 0
