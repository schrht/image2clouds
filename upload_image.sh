#!/bin/bash
#
# Description:
#   Upload the $IMAGE_FILE to Alibaba Cloud.
#
# History:
#   v1.0  2020-02-05  charles.shih  Init version

# Load profile and verify the veribles
source ./profile
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_REGION" ] && echo "\$ALIYUN_REGION is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_BUCKET" ] && echo "\$ALIYUN_BUCKET is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_FOLDER" ] && echo "\$ALIYUN_FOLDER is essintial but not existing, exit." && exit 1

# Check utilities
ossutil64 -v >/dev/null || exit 1

# Upload the image
echo "Uploading the image..."
echo "Location: oss://$ALIYUN_BUCKET/$ALIYUN_FOLDER/ (REGION: $ALIYUN_REGION)"
ossutil64 cp --endpoint http://oss-$ALIYUN_REGION.aliyuncs.com \
    $IMAGE_FILE oss://$ALIYUN_BUCKET/$ALIYUN_FOLDER/ || exit 1

exit 0
