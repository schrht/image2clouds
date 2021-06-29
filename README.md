# image2clouds
Deal with Red Hat Enterprise Linux Golden Image for public cloud usage.

# Usage

## Prepare the environment
You can run `./setup.sh` to prepare the environment, before that you need to get your AK/SK from Alibaba Cloud.
Example: AK=LTAIxxxxxxxxxxxx SK=HOBIjfxxxxxxxxxxxxxxxxxxxxxxxx

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
`./create_profile.sh [URL of the Golden Image]`  
URL example:  
`http://download.eng.pek2.redhat.com/pub/nightly/RHEL-8.2.0-20200203.n.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-181.x86_64.qcow2`  
**Note:** Now you have a chance to review and update parameters in `./profile`.  
For example:
```
./update_profile.sh ALIYUN_IMAGE_SIZE 100         # Update the qcow2 image disk size (GiB)
./update_profile.sh ALIYUN_BUCKET rhel-platform   # Update the Bucket Name
./update_profile.sh ALIYUN_REGION us-east-1       # Update the Bucket/Image Region 
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
10. [Optional] Specifiy an image name other than IMAGE_LABEL
`grep IMAGE_LABEL ./profile`
`./update_profile.sh ALIYUN_IMAGE_NAME <new_image_name>`
11.  Register the image on Alibaba Cloud
`./register_image.sh`

## Run all-in-one scripts

### For Platform testing
`./i2c_platform_test.sh <URL of the Golden Image>`

**Note:** It is recommended that you configure your account to not require a sudo password.
