#!/bin/bash

# Description:
#   This script is used to update the profile.
#
# Usage:
#   update_profile.sh <key> <value>
#
# History:
#   v1.0  2020-01-19  charles.shih  Init version
#   v2.0  2020-02-03  charles.shih  Split create_profile and update_profile

pf=./profile

# Verify the profile
[ ! -w "$pf" ] && echo "Target file ($pf) is unreadable or not existing." && exit 1

# Parse the parameters
if [ -z "$1" ]; then
	echo "Usage: $0 <key> <value>"
	exit 1
fi

# Update or add entry to the profile
grep -q "^$1=" $pf
if [ "$?" = "0" ]; then
	sed -i "s#^$1=.*#$1=$2#" $pf
else
	echo "$1=$2" >>$pf
fi

exit 0
