#!/bin/bash
#
# Description:
#   Customize $IMAGE_FILE for platform testing usage.
#
# History:
#   v1.0    2020-02-03  charles.shih  Init version
#   v1.0.1  2020-02-03  charles.shih  Bugfix for image file name
#   v1.1    2020-02-04  charles.shih  Define new image size
#   v1.2    2020-02-04  charles.shih  Change logic of placing repos

# Load profile and verify the veribles
source ./profile
[ -z "$WORKSPACE" ] && echo "\$WORKSPACE is essintial but not existing, exit." && exit 1
[ -z "$IMAGE_FILE" ] && echo "\$IMAGE_FILE is essintial but not existing, exit." && exit 1

# Check utilities
virt-customize -V >/dev/null || exit 1

# Enlarge the image
size=30
echo -e "\nEnlarge the image to $size GiB..."
fsize=$(ls -l $IMAGE_FILE | awk '{print $5}')
if [ "$fsize" -lt "$(($size * 1024 * 1024 * 1024))" ]; then
	qemu-img create -f qcow2 -o preallocation=metadata $WORKSPACE/newdisk.qcow2 ${size}G || exit 1
	virt-resize --expand /dev/sda1 $IMAGE_FILE $WORKSPACE/newdisk.qcow2 || exit 1
	mv -f $WORKSPACE/newdisk.qcow2 $IMAGE_FILE || exit 1
else
	echo -e "Already enlarged to $size GiB, skip this operation."
fi

# Place git repos
function place_repo() {
	local repo_name=$1
	local repo_url=$2

	read -t 30 -p "Place \"$repo_name\" into image [Y/n]? (in 30s) " answer
	[ "$answer" = "n" ] && return 0 || echo

	if [ -d "./$repo_name" ]; then
		read -t 30 -p "Run 'git pull' for \"$repo_name\" [y/N]? (in 30s) " answer
		[ "$answer" = "y" ] && bash -c "cd ./$repo_name && git pull" || echo
	else
		echo "Cloning repo..."
		git clone -c http.sslVerify=false $repo_url $repo_name || exit 1
	fi

	echo "Placing repo..."
	virt-customize -a $IMAGE_FILE --copy-in ./$repo_name:/root/ || exit 1

	return 0
}

place_repo platform-test git://git.engineering.redhat.com/users/darcari/platform-test.git
place_repo linus git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
place_repo kernel-rhel https://code.engineering.redhat.com/gerrit/kernel-rhel

# Reset SELinux label
echo -e "\nResetting SELinux label..."
virt-customize -a $IMAGE_FILE --selinux-relabel

exit 0
