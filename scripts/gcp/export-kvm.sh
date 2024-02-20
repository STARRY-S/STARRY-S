#!/bin/bash
#

gcloud compute instances export starry-kvm-2 \
  --destination=starry-1.yaml \
  --zone=asia-northeast1-b
