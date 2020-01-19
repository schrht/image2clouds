#!/bin/bash

# Description:
#   This script is used to create or update the profile.
#
# Usage:
#   update_profile.sh
#   update_profile.sh <Image URL>
#   update_profile.sh <key> <value>
#
# History:
#   v1.0  2020-01-19  charles.shih  Init version


function create() {
	# Show the overwrite information
	if [ -f "$pf" ]; then
		read -p "Overwrite target file ($pf) [y/N]?" answer
		[ "$answer" != "y" ] && exit 0
		: >$pf
	fi

	# Get image URL
	if [ ! -z "$1" ]; then
		image_url=$1
	elif [ -z "$image_url" ]; then
		read -p "Enter image URL: " image_url
	fi

	# Verify image URL
	# Ex. http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2
	[[ ! $image_url =~ .qcow2$ ]] && echo -e "ERROR: a qcow2 image is expected." && return 1

	# Parse other information
	image_name=$(basename $image_url)
	repo_baseurl=$(echo $image_url | sed 's#/compose.*##')
	image_label=$(basename $repo_baseurl)
	workspace="/var/lib/libvirt/images/$image_label"
	image_file="$workspace/$image_name"

	# Confirm the information
	echo -e "\nPlease confirm the following information:"
	echo -e "IMAGE URL:      $image_url"
	echo -e "IMAGE NAME:     $image_name"
	echo -e "IMAGE LABEL:    $image_label"
	echo -e "WORKSPACE:      $workspace"
	echo -e "IMAGE FILE:     $image_file"
	echo -e "REPO BASEURL:   $repo_baseurl"
	echo -e "\nIf you need a correction, press <Ctrl+C> in 30 seconds... Or press <Enter> to continue immediately..."
	read -t 30

	# Write profile
	echo -e "\nWriting to the target file ($pf)..."
	echo "IMAGE_URL=$image_url" >>$pf
	echo "IMAGE_NAME=$image_name" >>$pf
	echo "IMAGE_LABEL=$image_label" >>$pf
	echo "WORKSPACE=$workspace" >>$pf
	echo "IMAGE_FILE=$image_file" >>$pf
	echo "REPO_BASEURL=$repo_baseurl" >>$pf
}

function update() {
	# Verify the profile
	[ ! -w "$pf" ] && echo "Target file ($pf) is unreadable or not existing." && exit 1

	# Update or add entry to the profile
	grep -q "^$1=" $pf
	if [ "$?" = "0" ]; then
		sed -i "s#^$1=.*#$1=$2#" $pf
	else
		echo "$1=$2" >>$pf
	fi
}

pf=./profile

if [ -z "$2" ]; then
	create "$1"
else
	update "$1" "$2"
fi
