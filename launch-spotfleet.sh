#!/bin/bash

# ---- Config ----
JSON_FILE="spot_instance_request.json" # Path to your JSON file
KEY_FILE="my-key.pem" # Path to your .pem file
USER="ec2-user"   # Amazon Linux = ec2-user | Ubuntu = ubuntu

# ---- Step 1: Request Spot Fleet ----
echo "Requesting Spot Fleet..."
FLEET_ID=$(aws ec2 request-spot-fleet --spot-fleet-request-config file://$JSON_FILE --query "SpotFleetRequestId" --output text)
echo "Spot Fleet Request ID: $FLEET_ID"

# ---- Step 2: Wait until an Instance ID is assigned ----
echo "Waiting for instance to be assigned..."
INSTANCE_ID="None"
while [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; do
    sleep 10
    INSTANCE_ID=$(aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $FLEET_ID --query "ActiveInstances[0].InstanceId" --output text)
done

echo "Instance launched: $INSTANCE_ID"

# ---- Step 3: Get Public IP ----
PUBLIC_IP=""
while [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "None" ]; do
    sleep 5
    PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
done

echo "Public IP: $PUBLIC_IP"

# ---- Step 4: Wait until SSH is reachable ----
echo "Checking SSH availability on $PUBLIC_IP..."
SSH_READY=false
while [ "$SSH_READY" = false ]; do
    if nc -z -w5 "$PUBLIC_IP" 22 2>/dev/null; then
        SSH_READY=true
        echo "SSH is ready, connecting..."
    else
        sleep 5
    fi
done

# ---- Step 5: SSH into the instance ----
ssh -i "$KEY_FILE" "$USER@$PUBLIC_IP"
