#!/bin/bash
#
# Description:
#   Process the $IMAGE_FILE for general public cloud usage.
#
# History:
#   v1.0    2020-01-19  charles.shih  Init version
#   v1.0.1  2020-01-19  charles.shih  Bugfix for URL replacement

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1
[ -z "$REPO_BASEURL" ] && echo "\$REPO_BASEURL is essintial but not existing, exit." && exit 1

# Check utilities
virt-customize -V >/dev/null || exit 1

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

# Setup dnf repo
echo -e "Setting up dnf repo..."
cp ./source/rhel.repo $WORKSPACE/
sed -i "s#{{REPO_BASEURL}}#$REPO_BASEURL#" $WORKSPACE/rhel.repo
virt-customize -a $IMAGE_FILE --copy-in $WORKSPACE/rhel.repo:/etc/yum.repos.d/

# Reset SELinux label
echo -e "Resetting SELinux label..."
virt-customize -a $IMAGE_FILE --selinux-relabel

exit 0
