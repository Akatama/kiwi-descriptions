#!/bin/bash
while getopts p:c: flag
do
    case "${flag}" in
        p) path=${OPTARG};;
        c) credentialsPath=${OPTARG};;
    esac
done


mash account azure add --name azure --region centralus --source-container images --source-resource-group Tumbleweed \
    --source-storage-account Tumbleweed --credentials $credentialsPath && echo "added account"
JOB_ID=$(mash job azure add $path | grep -oP '(?<="job_id":) "(.*?)"' | tr -d '"')
echo $JOB_ID
mash job wait --job-id $JOB_ID
