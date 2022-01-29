#!/bin/bash
#
# Description:
#   Deal with RHEL Golden Image for platform testing usage.
#
# Usage:
#   i2c_platform_test.sh <URL of the RHEL Golden Image>
#
# History:
#   v1.0  2020-02-05  charles.shih  Init version
#   v1.1  2020-02-10  Update ALIYUN_BUCKET and ALIYUN_REGION in profile
#   v1.2  2020-02-10  Support running from anywhere

set -e

if [ -z "$1" ]; then
	echo -e "Usage:\n$0 <URL of the RHEL Golden Image>"
	echo -e "Example:\n$0 http://download.xxx.xxxxxx.com/rhel-x/nightly/RHEL-x/xxxxxxxxxxxx/compose/BaseOS/xxxxxx/images/rhel-guest-image-xxxx-xxxxxxxx.x.xxxxxx.qcow2"
	exit 1
fi

$(dirname $0)/create_profile.sh $1
$(dirname $0)/update_profile.sh ALIYUN_IMAGE_SIZE 100
$(dirname $0)/update_profile.sh ALIYUN_BUCKET rhel-platform
$(dirname $0)/update_profile.sh ALIYUN_REGION us-east-1

$(dirname $0)/download_image.sh
$(dirname $0)/process_image.sh
$(dirname $0)/customize_platform_test.sh

$(dirname $0)/define_vm.sh
$(dirname $0)/start_vm.sh
$(dirname $0)/get_vm_info.sh
$(dirname $0)/vm_execute.sh 'cd /root/platform-test/init && ./run.sh'
$(dirname $0)/vm_execute.sh 'cd /root/platform-test && ./run.sh'
$(dirname $0)/stop_vm.sh
$(dirname $0)/undefine_vm.sh

$(dirname $0)/upload_image.sh
$(dirname $0)/register_image.sh

exit 0
