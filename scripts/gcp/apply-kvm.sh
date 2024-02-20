#!/bin/bash

gcloud compute instances update-from-file starry-kvm-2 \
    --source=starry-1.yaml \
    --most-disruptive-allowed-action=RESTART \
    --zone=asia-northeast1-b
