#!/bin/bash
#
# Description:
#   Check the state of VM.
#
# History:
#   v1.0  2020-02-10  charles.shih  Init version
#   v1.1  2020-02-10  charles.shih  Show N/A if $DOMAIN_NAME unavailable

# Parse parameters
if [ "$1" != "" ] && [ "$1" != "running" ] && [ "$1" != "shutoff" ] && [ "$1" != "undefined" ]; then
	echo -e "Usage:\n$0 <running|shutoff|undefined>"
	exit 1
fi

# Load profile and verify the veribles
source ./profile

if [ ! -z "$DOMAIN_NAME" ]; then
	# Get sudo access
	sudo bash -c : || exit 1

	# Check utilities
	sudo virsh --version >/dev/null || exit 1

	# Get VM state
	state=$(sudo virsh list --all | grep -w "\s$DOMAIN_NAME\s" | awk '{print $3$4}')
fi

: ${state:=undefined}

# Show VM state
echo "Name: ${DOMAIN_NAME:-"N/A"}  State: $state  Want: $1"

[ "$state" = "$1" ] && exit 0 || exit 1
