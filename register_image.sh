#!/bin/bash
#
# Description:
#   Register the uploaded image on Alibaba Cloud.
#
# History:
#   v1.0  2020-02-05  charles.shih  Init version

# Load profile and verify the veribles
source ./profile
[ -z "$IMAGE_NAME" ] && echo "\$IMAGE_NAME is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_REGION" ] && echo "\$ALIYUN_REGION is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_BUCKET" ] && echo "\$ALIYUN_BUCKET is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_FOLDER" ] && echo "\$ALIYUN_FOLDER is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_LABEL" ] && echo "\$IMAGE_LABEL is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_IMAGE_SIZE" ] && echo "\$ALIYUN_IMAGE_SIZE is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_IMAGE_DESC" ] && echo "\$ALIYUN_IMAGE_DESC is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_ARCH" ] && echo "\$IMAGE_ARCH is essintial but not existing, exit." && exit 1

if [ -z "$ALIYUN_IMAGE_NAME" ]; then
    echo "\$ALIYUN_IMAGE_NAME is not provisioned, using \$IMAGE_LABEL."
    ALIYUN_IMAGE_NAME=$IMAGE_LABEL-$IMAGE_ARCH
fi

# Check utilities
aliyun --version >/dev/null || exit 1

# Upload the image
echo "Register image as \"$ALIYUN_IMAGE_NAME\"..."
aliyun ecs ImportImage --RegionId $ALIYUN_REGION \
    --DiskDeviceMapping.1.OSSBucket $ALIYUN_BUCKET \
    --DiskDeviceMapping.1.OSSObject $ALIYUN_FOLDER/$IMAGE_NAME \
    --DiskDeviceMapping.1.DiskImageSize $ALIYUN_IMAGE_SIZE \
    --OSType Linux --ImageName $ALIYUN_IMAGE_NAME \
    --Architecture x86_64 --Platform RedHat \
    --Description "$ALIYUN_IMAGE_DESC"

exit 0
