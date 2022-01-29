#!/bin/bash
#
# Description:
#   Upload BYOS Image for Alibaba Cloud.
#
# Usage:
#   alibaba_typical.sh <URL of the RHEL Golden Image>
#
# History:
#   v1.0  2022-01-28  charles.shih  Init version

set -e

if [ -z "$1" ]; then
	echo -e "Usage:\n$0 <URL of the RHEL Golden Image>"
	echo -e "Example:\n$0 http://download.xxx.xxxxxx.com/rhel-x/nightly/RHEL-x/xxxxxxxxxxxx/compose/BaseOS/xxxxxx/images/rhel-guest-image-xxxx-xxxxxxxx.x.xxxxxx.qcow2"
	exit 1
fi

$(dirname $0)/create_profile.sh $1
$(dirname $0)/download_image.sh
$(dirname $0)/process_image.sh
$(dirname $0)/upload_image.sh
$(dirname $0)/register_image.sh

exit 0

