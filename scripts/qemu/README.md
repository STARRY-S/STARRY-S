# Ubuntu 20.04 libvirt KVM

Run following script to install `virt-manager` and setup 3 ubuntu KVM instances.

Available to run on Ubuntu & Debian with KVM enabled.

> Note: **The host system is required to be at least 8C16G, disk space >= 150G.**

```sh
git clone https://github.com/STARRY-S/STARRY-S.git && cd STARRY-S/scripts/qemu

./prepare-livirt.sh
```

View the status of the KVM instances.

```console
$ sudo virsh list --all
 Id   Name       State
--------------------------
 1    ubuntu-1   running
 2    ubuntu-2   running
 3    ubuntu-3   running

$ ssh ubuntu@192.168.122.101
$ ssh ubuntu@192.168.122.102
$ ssh ubuntu@192.168.122.103
```

> The default user password is defined [in userdata-N.yaml](./userdata-1.yaml), modify or change to use `ssh_authorized_keys` for safety purpose.
