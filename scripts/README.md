# Installation Notes

This is a guide of how I am setting up the prerequisites on my homeserver, running Ubuntu server. In order to be able to start the homelab you'll need to first run the script and then to manually execute commands in order to personalize more the experience. This guide will help you just that.


## Download the installation script
I created a separated install script out of the original start.sh.


```console
/bin/bash -c "$(curl -s https://raw.githubusercontent.com/dhont/homelab-docker/main/scripts/install.sh)"
```
OR (Recommended) download and *updatethe file as needed*  before execution : 

```console
curl -s https://raw.githubusercontent.com/dhont/homelab-docker/main/scripts/install.sh
chmod +x install.sh
./install.sh
```
## Update the installation script

Have a look a the variables in this file and adjust as needed. Prior to running the script create the configuration files in /configtemplates folder.

### Configure mount of remote NFS share (NAS, etc)

Update with your NAS IP and add: 192.168.1.100:/homelab /media/nfs  nfs defaults,bg 0 0
```console
sudo nano /etc/fstab
```
Test and persist the mount:
```console
sudo umount /media/nfs
sudo mount -a
```

## Run the installation script

```console
sudo ./install.sh
```