#!/bin/bash
#
# Description:
#   Process the $IMAGE_FILE for general public cloud usage.
#
# History:
#   v1.0    2020-01-19  charles.shih  Init version
#   v1.0.1  2020-02-03  charles.shih  Bugfix for URL replacement
#   v1.1    2020-02-10  charles.shih  Check VM state before executing
#   v1.2    2020-02-10  charles.shih  Make this script can be running from anywhere
#   v1.3    2021-07-16  charles.shih  Append "PermitRootLogin yes" to sshd_config

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$REPO_BASEURL" ] && echo "\$REPO_BASEURL is essintial but not existing, exit." && exit 1

# Check utilities
virt-customize -V >/dev/null || exit 1

# Check VM state
$(dirname $0)/check_vm_state.sh undefined
if [ "$?" != "0" ]; then
	$(dirname $0)/check_vm_state.sh shutoff
	if [ "$?" != "0" ]; then
		echo "ERROR: The VM must be stopped first."
		exit 1
	fi
fi

# Modify root password if configured
if [ ! -z "$ROOT_PASSWD" ]; then
	echo -e "Setting root password..."
	virt-customize -a $IMAGE_FILE --root-password password:$ROOT_PASSWD
fi

# Set authorized key
echo -e "Setting authorized key..."
if [ ! -r "$SSH_IDENTITY" ]; then
	echo "The file specified by \$SSH_IDENTITY is unreadable or not existing. Override with \"$PWD/mycert\"."
	SSH_IDENTITY=$PWD/mycert
	$(dirname $0)/update_profile.sh SSH_IDENTITY $SSH_IDENTITY
fi

if [ ! -r "$SSH_IDENTITY" ]; then
	echo "Creating SSH identity files..."
	ssh-keygen -t rsa -N "" -f $SSH_IDENTITY -q
fi

virt-customize -a $IMAGE_FILE --ssh-inject root:string:"$(ssh-keygen -y -f $SSH_IDENTITY)"

# Setup cloud-init
echo -e "Setting up cloud-init..."
rhel_ver=${IMAGE_LABEL:5:3}
if [ "$(echo "$rhel_ver>=8.4" | bc)" = "0" ]; then
	cp $(dirname $0)/source/cloud.cfg.aliyun_rhel77 $WORKSPACE/cloud.cfg
else
	cp $(dirname $0)/source/cloud.cfg.aliyun_rhel84 $WORKSPACE/cloud.cfg
fi
virt-customize -a $IMAGE_FILE --copy /etc/cloud/cloud.cfg:/etc/cloud/cloud.cfg.bak
virt-customize -a $IMAGE_FILE --copy-in $WORKSPACE/cloud.cfg:/etc/cloud/

# Update sshd_config (RHEL9)
rhel_ver=${IMAGE_LABEL:5:3}
if [ "$(echo "$rhel_ver>=9.0" | bc)" != "0" ]; then
	echo -e "Updating sshd_config..."
	virt-customize -a $IMAGE_FILE --append-line "/etc/ssh/sshd_config:PermitRootLogin yes"
fi

# Setup dnf repo
echo -e "Setting up dnf repo..."
cp $(dirname $0)/source/rhel.repo $WORKSPACE/
sed -i "s#{{REPO_BASEURL}}#$REPO_BASEURL#" $WORKSPACE/rhel.repo
virt-customize -a $IMAGE_FILE --copy-in $WORKSPACE/rhel.repo:/etc/yum.repos.d/

# Reset SELinux label
echo -e "Resetting SELinux label..."
virt-customize -a $IMAGE_FILE --selinux-relabel

exit 0
