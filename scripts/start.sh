#####
# Configure the below variables
#####

varBackupDir=/home/user/backup
varConfigDir=/srv/docker
varOptDir=/opt/docker/homelab
varMediaStorage=/media/storage # attached SSD for direct downloads, cache, db
varRemoteMediaStorage=/media/nas # metwork storage for media, backups - large storage (RAID0)





#####
# Anything below this doesn't need changing, unless you want to customize your homelab
#####

# File System: Configuration and Core Options
cd /srv
mkdir -p {docker,cache,logs}
cd $varOptDir
git clone https://github.com/dhont/homelab-docker.git


# File System: Media storage (aka your files)
cd $varMediaStorage # This uses MergerFS. For a simpler version, use /data
mkdir -p db
mkdir -p downloads/{audiobooks,music,podcasts,movies,tv}

mkdir -p staticfiles
sudo chown -R $USER:$USER $varMediaStorage/{db,downloads,media,staticfiles}
sudo chmod -R a=,a+rX,u+w,g+w $varMediaStorage/{db,downloads,media,staticfiles}

# Network Storage: Media storage (aka your files)
cd $varRemoteMediaStorage # This uses NFS
mkdir -p downloads/{audiobooks,music,podcasts,movies,tv}




# SnapRaid
cp $varOptDir/configtemplates/snapraid/snapraid.conf /etc/snapraid.conf
mkdir -p /var/snapraid

# ghs
cp -rpi $varOptDir/configtemplates/ghs/application.properties $varConfigDir/ghs/application.properties

# homepage
cp -rpi $varOptDir/configtemplates/homepage $varConfigDir/homepage

# Pihole
cp -rpi $varOptDir/configtemplates/pihole/resolv.conf $varConfigDir/pihole/resolv.conf

# Samba
sudo apt install samba
cp -rpi $varOptDir/configtemplates/samba/smb.conf /etc/samba/smb.conf
sudo ufw allow samba

# nfs
# sudo apt install nfs-common

# Unbound
cp -rpi $varOptDir/configtemplates/unbound/* $varConfigDir/unbound



# Docker Setup
sudo groupadd docker
sudo usermod -aG docker $USER

docker network create web
docker network create caddy-net
docker network create -d bridge subnet 192.168.1.0/24 dns-net
docker volume create crowdsec-config
docker volume create crowdsec-db


# Print user info
id


# Jellyfin
useradd jellyfin
usermod -aG render jellyfin
id jellyfin
