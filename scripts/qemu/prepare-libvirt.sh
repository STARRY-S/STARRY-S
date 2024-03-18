#!/bin/bash

cd $(dirname $0)/
WORKDIR=$(pwd)

set -exuo pipefail

CLOUD_IMG="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
LIBVIRT_PATH="/var/lib/libvirt"

sudo apt-get update
sudo apt-get -y install virt-manager cloud-image-utils

echo "Initializing libvirt default network"

DEFAULT_NETWORK_UUID=$(sudo virsh net-dumpxml default | grep '<uuid>' | sed -e 's/^[[:space:]]*//')
DEFAULT_NETWORK_UUID=${DEFAULT_NETWORK_UUID##'<uuid>'}
DEFAULT_NETWORK_UUID=${DEFAULT_NETWORK_UUID%%'</uuid>'}
sed -i "s/DEFAULT_NETWORK_UUID/${DEFAULT_NETWORK_UUID}/g" default-network.xml
echo "Update default network XML:"
sudo virsh net-define ./default-network.xml
sudo virsh net-autostart default || true
sudo virsh net-start default || true

if ! grep -q '192.168.122.101' /etc/hosts; then
    sudo bash -c "echo '192.168.122.101   ubuntu-1' >> /etc/hosts"
    sudo bash -c "echo '192.168.122.102   ubuntu-2' >> /etc/hosts"
    sudo bash -c "echo '192.168.122.103   ubuntu-3' >> /etc/hosts"
fi

sudo mkdir -p $LIBVIRT_PATH/images
# Grant read permission for other users
sudo chmod -R 755 $LIBVIRT_PATH
cd $LIBVIRT_PATH/images

# Download
echo "Downloading the ubuntu KVM image..."
if [[ -e 'ubuntu.img' ]]; then
    sudo rm ubuntu.img
fi
sudo wget $CLOUD_IMG -O ubuntu.img
sudo cp ubuntu.img ubuntu-1.qcow2
sudo cp ubuntu.img ubuntu-2.qcow2
sudo cp ubuntu.img ubuntu-3.qcow2
echo "Resize ubuntu qcow2 disk image to 40G"
sudo qemu-img resize ubuntu-1.qcow2 40G
sudo qemu-img resize ubuntu-2.qcow2 40G
sudo qemu-img resize ubuntu-3.qcow2 40G

cd $WORKDIR
echo "Create user-data"
cloud-localds userdata-1.img userdata-1.yaml
cloud-localds userdata-2.img userdata-2.yaml
cloud-localds userdata-3.img userdata-3.yaml
sudo mv ./*.img $LIBVIRT_PATH/images

echo "Define libvirt VM XML domains"
sudo virsh define ./ubuntu-1.xml
sudo virsh define ./ubuntu-2.xml
sudo virsh define ./ubuntu-3.xml

sudo virsh list --all

echo "Use 'virsh start ubuntu-N' to boot up
Use 'virsh shutdown ubuntu-N' to shutdown
Use 'virsh destroy ubuntu-N' to force shutdown
Use 'ssh root@192.168.122.10N' to connect the VM
Done"
