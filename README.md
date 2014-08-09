# createvm.sh

Create VMware virtual machines from the command line.

**This is an old project I moved from Google Code to here :)**


createvm.sh is a script written in bash. With createvm you can create a VMware virtual machine with one command. It was made to  automate the process of creating Virtual Machines.

It supports a couple of command line parameters which allow you to configure the VM you are creating. 


## Examples 
Here are some examples:

##### Create an Ubuntu Linux machine with a 20GB hard disk and a different name

    createvm.sh ubuntu -d 20 -n "My Ubuntu VM"

##### Silently create a SUSE Linux machine with 512MB ram, a fixed MAC address and zip it

    createvm.sh suse -r 512 -q -m 00:50:56:01:25:00 -z 

##### Create a Windows XP machine with 512MB and audio, USB and CD enabled

    createvm.sh winXPPro -r 512 -a -u -c

##### Create an Ubuntu VM with 512MB and open and run it in vmware

    createvm.sh ubuntu -r 512 -x "vmware -x"

##### Create 10 VM's with a custom name and MAC address

    for VM_ID in `seq -w 01 10`; do  ./createvm.sh winXPPro -y -n Workstation-$VM_ID -m 00:50:56:01:01:$VM_ID; done
