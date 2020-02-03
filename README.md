# golden_image_to_clouds
Deal with Red Hat Enterprise Linux Golden Image for public cloud usage.

# Steps
1. Create profile  
`./create_profile.sh [URL of the Golden Image]`  
URL example:  
`http://download.eng.pek2.redhat.com/pub/nightly/RHEL-8.2.0-20200203.n.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-181.x86_64.qcow2`
2. Download golden image  
`./download_image.sh`
3. Process image for general cloud usage  
`./process_image.sh`
4. [Optional] Customize image for platform testing (1/2)  
`./customize_image_plattest.sh`
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
