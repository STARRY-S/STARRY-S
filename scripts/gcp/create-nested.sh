#!/bin/bash
#

set -x

gcloud compute instances create starry-kvm-1 \
  --enable-nested-virtualization \
  --zone="asia-northeast1-b"  \
  --min-cpu-platform="Intel Haswell" \
  --boot-disk-size="40G" \
  --machine-type="n1-standard-4" \
  --provisioning-model=SPOT \
  --source-instance-template='projects/ei-container-platform-dev/regions/asia-northeast1/instanceTemplates/starry-1' \
