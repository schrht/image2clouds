#!/bin/bash
#
# Description:
#   Parse image URL and download the image from internal file server to $WORKSPACE.
#
# History:
#   v1.0  2020-01-19  charles.shih  Init version

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
	cp -i ${IMAGE_FILE}.origin $IMAGE_FILE
fi

exit 0
