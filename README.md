# image2clouds
Customize and upload Red Hat Enterprise Linux Golden Image to public clouds.  

# Usage (Alibaba)

## Prepare the environment
Run `./setup.sh` to setup the environment.

Get "Access Key Id" and "Access Key Secret" from Alibaba before starting.

Please follow the example for provisioning:  

```
$ ./setup.sh 

Checking packages...

Looking up package git...
git-2.17.2-2.fc28.x86_64

Looking up package libguestfs...
libguestfs-1.38.6-1.fc28.x86_64

Looking up package libguestfs-tools-c...
libguestfs-tools-c-1.38.6-1.fc28.x86_64

Looking up package libvirt...
libvirt-4.1.0-6.fc28.x86_64

Looking up package libvirt-client...
libvirt-client-4.1.0-6.fc28.x86_64

Configuring libvirt...

Checking Aliyun CLI...
/usr/local/bin/aliyun
Configure Access Key for Aliyun CLI now [y/N]? (in 30s) y
Configuring profile 'default' in 'AK' authenticate mode...
Access Key Id []: LTAIxxxxxxxxxxxx
Access Key Secret []: HOBIjfxxxxxxxxxxxxxxxxxxxxxxxx
Default Region Id []: cn-beijing
Default Output Format [json]: json (Only support json)
Default Language [zh|en] en: 
Saving profile[default] ...Done.

Configure Done!!!

Checking Aliyun OSSUitl...
/usr/local/bin/ossutil64
Configure Access Key for Aliyun OSSUtil now [y/N]? (in 30s) y
The command creates a configuration file and stores credentials.

Please enter the config file path(default $HOME/.ossutilconfig, carriage return will use the default path. If you specified this option to other path, you should specify --config-file option to the path when you use other commands):

For the following settings, carriage return means skip the configuration. Please try "help config" to see the meaning of the settings
Please enter accessKeyID:LTAIxxxxxxxxxxxx
Please enter accessKeySecret:HOBIjfxxxxxxxxxxxxxxxxxxxxxxxx
Please enter stsToken:
Please enter endpoint:http://oss-cn-beijing.aliyuncs.com 
```

## Steps for image processing
1. Create profile  
`./create_profile.sh [RHEL guest image URL]`  

URL example:  
`http://download.eng.pek2.redhat.com/rhel-9/nightly/RHEL-9-Beta/RHEL-9.0.0-20210713.3/compose/BaseOS/x86_64/images/rhel-guest-image-9.0-20210713.t.21.x86_64.qcow2`

**Note:** Now you have a chance to review and update parameters in `./profile`.

For example:
```
./update_profile.sh ALIYUN_IMAGE_SIZE 100         # Update the qcow2 image disk size (GiB)
./update_profile.sh ALIYUN_BUCKET rhel-platform   # Update the Bucket Name
./update_profile.sh ALIYUN_REGION us-east-1       # Update the Bucket/Image Region 
./update_profile.sh ALIYUN_IMAGE_ARCH <x86_64/arm64/i386>  # Update the Image Arch
```

2. Download golden image  
`./download_image.sh`

3. Process image for general cloud usage  
`./process_image.sh`

4. [Optional] Customize image for platform testing (1/2)  
`./customize_platform_test.sh`

5. [Optional] Run VM  
`./define_vm.sh`  
`./start_vm.sh`  
`./get_vm_info.sh`  

6. [Optional] Customize image for platform testing (2/2)  
`./vm_execute.sh 'cd /root/platform-test/init && ./run.sh'`  
`./vm_execute.sh 'cd /root/platform-test && ./run.sh'`

7. [Optional] Stop VM  
`./stop_vm.sh`  
`./undefine_vm.sh`

8. Upload the image to Alibaba Cloud  
`./upload_image.sh`

9. [Optional] Change the image size from 40G to 100G (for platform_test)  
`./update_profile.sh ALIYUN_IMAGE_SIZE 100`

10. [Optional] Specify an image name other than IMAGE_LABEL  
`grep IMAGE_LABEL ./profile`  
`./update_profile.sh ALIYUN_IMAGE_NAME <new_image_name>`

11. [Optional] Specify an image architecture other than x86_64  
`./update_profile.sh ALIYUN_IMAGE_ARCH <x86_64/arm64/i386>`

11.  Register the image on Alibaba Cloud  
`./register_image.sh`

## Run all-in-one scripts

**Note:** It is recommended to configure your account to not ask for a sudo password.

### For Alibaba BYOS image validation
`./alibaba_byos.sh <RHEL guest image URL>`

### For Platform testing  
`./i2c_platform_test.sh <RHEL guest image URL>`


