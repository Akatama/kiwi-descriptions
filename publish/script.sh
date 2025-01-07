#!/bin/bash
mash account azure add --name azure --region centralus --source-container images --source-resource-group Tumbleweed --source-storage-account Tumbleweed --credentials /mnt/tumbleweedSP.json && echo "added account"
AARCH_JOB_ID=$(mash job azure add /mnt/mash/azure_aarch64.job | grep -oP '(?<="job_id":) "(.*?)"' | tr -d '"')
echo $AARCH_JOB_ID
mash job wait --job-id $AARCH_JOB_ID
