#!/bin/bash
#
# Description:
#   Parse image URL and download the image from internal file server to $WORKSPACE.
#
# History:
#   v1.0  2020-01-19  charles.shih  Init version
#   v1.1  2020-02-05  charles.shih  Change the overwrite as default

# Load profile and verify the veribles
source ./profile
[ -z "$IMAGE_URL" ] && echo "\$IMAGE_URL is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1

# Go to workspace
mkdir -p $WORKSPACE && cd $WORKSPACE

# Download the image
echo -e "\nDownloading image to $WORKSPACE..."
if [ ! -e ${IMAGE_FILE}.origin ]; then
	wget $IMAGE_URL
	wget ${IMAGE_URL}.MD5SUM
	md5sum -c ${IMAGE_FILE}.MD5SUM || exit 1
	cp $IMAGE_FILE ${IMAGE_FILE}.origin
else
	if [ -f "$IMAGE_FILE" ]; then
		read -t 30 -p "The image file already exists, overwirte [Y/n]? (in 30s) " answer
		echo
		[ "$answer" = "n" ] && exit 0		
	fi
	cp -f ${IMAGE_FILE}.origin $IMAGE_FILE
fi

exit 0
