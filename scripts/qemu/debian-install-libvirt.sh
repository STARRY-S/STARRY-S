#!/bin/bash

cd $(dirname $0)/
WORKDIR=$(pwd)

set -exuo pipefail

sudo apt install virt-manager

sudo virsh net-autostart default
sudo virsh net-start default

mkdir -p $HOME/libvirt

# Download ubuntu image
wget https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso
mv ubuntu-*.iso $HOME/libvirt/ubuntu.iso

if [[ ! -e "$HOME/libvirt/ubuntu-1.qcow2" ]]; then
    qemu-img create -f qcow2 $HOME/libvirt/ubuntu-1.qcow2 30G
fi
if [[ ! -e "$HOME/libvirt/ubuntu-2.qcow2" ]]; then
    qemu-img create -f qcow2 $HOME/libvirt/ubuntu-2.qcow2 30G
fi
