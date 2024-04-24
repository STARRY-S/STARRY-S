#!/bin/bash
#
# Script to launch KVM instance on GCP.

set -x

gcloud compute instances create starry-kvm-1 \
  --enable-nested-virtualization \
  --zone="asia-northeast1-b"  \
  --min-cpu-platform="Intel Haswell" \
  --source-instance-template='projects/ei-container-platform-dev/regions/asia-northeast1/instanceTemplates/starry-kvm-ubuntu-2004-8c16g' \

# starry-kvm-ubuntu-2004-8c16g: 8C 16G Ubuntu 20.04 LTS, can run 3 nested KVM
# starry-kvm-debian-6c10g: 6C 10G Debian 12, can run 2 nested KVM

  # --machine-type="n1-standard-16" \
  # --boot-disk-size="100G" \
