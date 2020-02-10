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

set -e

if [ -z "$1" ]; then
	echo -e "Usage:\n$0 <URL of the RHEL Golden Image>"
	echo -e "Example:\n$0 http://download.eng.pek2.redhat.com/pub/nightly/RHEL-8.2.0-20200203.n.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-181.x86_64.qcow2"
	exit 1
fi

./create_profile.sh $1
./update_profile.sh ALIYUN_IMAGE_SIZE 100
./update_profile.sh ALIYUN_BUCKET rhel-platform
./update_profile.sh ALIYUN_REGION us-east-1

./download_image.sh
./process_image.sh
./customize_platform_test.sh

./define_vm.sh
./start_vm.sh
./get_vm_info.sh
./vm_execute.sh 'cd /root/platform-test/init && ./run.sh'
./vm_execute.sh 'cd /root/platform-test && ./run.sh'
./stop_vm.sh
./undefine_vm.sh

./upload_image.sh
./register_image.sh

exit 0
