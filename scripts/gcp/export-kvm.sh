#!/bin/bash
#

gcloud compute instances export starry-ubuntu-worker \
  --destination=starry-1.yaml \
  --zone=asia-northeast1-b
