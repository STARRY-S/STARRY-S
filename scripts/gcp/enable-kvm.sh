#!/bin/bash
#

gcloud compute instances export starry-1 \
  --destination=starry-1.yaml \
  --zone=asia-northeast1-b
