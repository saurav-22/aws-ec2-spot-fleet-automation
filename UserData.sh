#!/bin/bash
sudo yum update -y
aws s3 cp s3://<YOUR-BUCKET-NAME>/packages-installation.sh /tmp/UserData.sh #Update your bucket name
chmod +x /tmp/UserData.sh
/tmp/UserData.sh
