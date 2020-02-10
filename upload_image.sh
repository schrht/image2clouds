#!/bin/bash
#
# Description:
#   Upload the $IMAGE_FILE to Alibaba Cloud.
#
# History:
#   v1.0  2020-02-05  charles.shih  Init version
#   v1.1  2020-02-10  charles.shih  Check VM state before executing

# Load profile and verify the veribles
source ./profile
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_REGION" ] && echo "\$ALIYUN_REGION is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_BUCKET" ] && echo "\$ALIYUN_BUCKET is essintial but not existing, exit." && exit 1
[ -z "$ALIYUN_FOLDER" ] && echo "\$ALIYUN_FOLDER is essintial but not existing, exit." && exit 1

# Check utilities
ossutil64 -v >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh undefined
if [ "$?" != "0" ]; then
	$(dirname $0)/check_vm_state.sh shutoff
	if [ "$?" != "0" ]; then
		echo "ERROR: The VM must be stopped first."
		exit 1
	fi
fi

# Upload the image
echo "Uploading the image..."
echo "Location: oss://$ALIYUN_BUCKET/$ALIYUN_FOLDER/ (REGION: $ALIYUN_REGION)"
ossutil64 cp --endpoint http://oss-$ALIYUN_REGION.aliyuncs.com \
    $IMAGE_FILE oss://$ALIYUN_BUCKET/$ALIYUN_FOLDER/ || exit 1

exit 0
