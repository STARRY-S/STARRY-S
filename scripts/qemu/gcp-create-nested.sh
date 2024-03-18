#!/bin/bash
#
# Script to launch KVM instance on GCP.

set -x

gcloud compute instances create starry-kvm-ubuntu-2004-1 \
  --enable-nested-virtualization \
  --zone="asia-northeast1-b"  \
  --min-cpu-platform="Intel Haswell" \
  --source-instance-template='projects/ei-container-platform-dev/regions/asia-northeast1/instanceTemplates/starry-kvm-ubuntu-2004-1' \

  # --machine-type="n1-standard-16" \
  # --boot-disk-size="100G" \
