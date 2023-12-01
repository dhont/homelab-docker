#####
# 1. Configure the below variables
#####

varBackupDir=/home/nfs/homelab-backup
varConfigDir=/srv/docker
varOptDir=/opt/docker/homelab
varMediaStorage=/media/storage # attached SSD for direct downloads, cache, db
varRemoteMediaStorage=/media/nas # metwork storage for media, backups - large storage (RAID0)
varSubnet=192.168.1.0/24


#####
Reusable functions
#####

add_user_if_not_exists() {
    local username="$1"
    if ! grep -q "^$username:" /etc/passwd; then
        sudo useradd "$username"
        echo "User $username added."
    else
        echo "User $username already exists."
    fi
}

add_group_if_not_exists() {
    local groupname="$1"
    if ! getent group "$groupname" > /dev/null; then
        sudo groupadd "$groupname"
        echo "Group $groupname added."
    else
        echo "Group $groupname already exists."
    fi
}

add_docker_network_if_not_exists() {
    local network_name="$1"
    if ! docker network ls --format "{{.Name}}" | grep -wq "$network_name"; then
        add_docker_network_if_not_exists "$network_name"
        echo "Docker network '$network_name' created."
    else
        echo "Docker network '$network_name' already exists."
    fi
}

#####
echo Install Prerequisites
#####

sudo apt install nfs-common samba docker

# 3. File System: Configuration and Core Options
cd /srv
mkdir -p {docker,cache,logs}
cd $varOptDir
git clone https://github.com/dhont/homelab-docker.git

# 4. File System: Media storage (aka your files)
cd $varMediaStorage # This uses MergerFS. For a simpler version, use /data
mkdir -p db
mkdir -p downloads/{audiobooks,music,podcasts,movies,tv}

mkdir -p staticfiles
sudo chown -R $USER:$USER $varMediaStorage/{db,downloads,media,staticfiles}
sudo chmod -R a=,a+rX,u+w,g+w $varMediaStorage/{db,downloads,media,staticfiles}

# Network Storage: Media storage (aka your files)
cd $varRemoteMediaStorage # This uses NFS
mkdir -p downloads/{audiobooks,music,podcasts,movies,tv}

# 5. Copy config files

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
cp -rpi $varOptDir/configtemplates/samba/smb.conf /etc/samba/smb.conf
sudo ufw allow samba

# Unbound
cp -rpi $varOptDir/configtemplates/unbound/* $varConfigDir/unbound

# 6. Docker Setup
add_group_if_not_exists "docker"
sudo usermod -aG docker $USER

add_docker_network_if_not_exists "web"
add_docker_network_if_not_exists "caddy-net"
docker network create -d bridge --subnet="172.20.0.0/16" dns-net
docker volume create crowdsec-config
docker volume create crowdsec-db


# 7. Jellyfin

add_user_if_not_exists "jellyfin"
sudo usermod -aG render jellyfin
id jellyfin





