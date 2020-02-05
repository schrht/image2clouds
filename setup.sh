#!/bin/bash
#
# Description:
#   Prepare the environment.
#
# History:
#   v1.0  2020-02-04  charles.shih  Init version
#   v1.1  2020-02-05  charles.shih  Setup Aliyun CLI and OSSUitl
#   v1.2  2020-02-05  charles.shih  Grant permission to the image path

# Get sudo access
sudo bash -c : || exit 1

# Check packages
echo -e "\nChecking packages..."
packages="
git
libguestfs
libguestfs-tools-c
libvirt
libvirt-client
"

for name in $packages; do
	echo -e "\nLooking up package $name..."
	rpm -q $name && continue

	echo "Installing package $name..."
	sudo dnf install -y $name
done

# Configure libvirt
echo -e "\nConfiguring libvirt..."
sudo chmod a+rwx /var/lib/libvirt/images/
#sudo sed -i 's/^#user = "root"/user = "root"/' /etc/libvirt/qemu.conf
#sudo sed -i 's/^#group = "root"/group = "root"/' /etc/libvirt/qemu.conf
sudo systemctl restart libvirtd
sudo systemctl enable libvirtd

# Setup Aliyun CLI
# Ref. https://www.alibabacloud.com/help/doc-detail/110244.html
echo -e "\nChecking Aliyun CLI..."
which aliyun
if [ "$?" != "0" ]; then
	mkdir -p $HOME/aliyun
	pushd $HOME/aliyun
	wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz
	tar -xf ./aliyun-cli-linux-latest-amd64.tgz
	chmod 755 ./aliyun
	sudo cp ./aliyun /usr/local/bin
	popd
fi

read -t 30 -p "Configure Access Key for Aliyun CLI now [y/N]? (in 30s) " answer
[ "$answer" = "y" ] && aliyun configure

# Setup Aliyun OSSUtil
# Ref. https://www.alibabacloud.com/help/doc-detail/50452.html
echo -e "\nChecking Aliyun OSSUitl..."
which ossutil64
if [ "$?" != "0" ]; then
	mkdir -p $HOME/aliyun
	pushd $HOME/aliyun
	wget http://gosspublic.alicdn.com/ossutil/1.6.6/ossutil64
	chmod 755 ./ossutil64
	sudo cp ./ossutil64 /usr/local/bin
	popd
fi

read -t 30 -p "Configure Access Key for Aliyun OSSUtil now [y/N]? (in 30s) " answer
[ "$answer" = "y" ] && ossutil64 config

exit 0
