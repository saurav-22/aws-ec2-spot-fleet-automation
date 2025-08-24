# ---- Config ----
$JsonFile = "spot_instance_request.json"
$KeyFile  = "C:\Users\YourUser\Downloads\my-key.pem"
$User     = "ec2-user"   # Amazon Linux = ec2-user | Ubuntu = ubuntu

# ---- Step 1: Request Spot Fleet ----
$FleetId = aws ec2 request-spot-fleet --spot-fleet-request-config file://$JsonFile --query "SpotFleetRequestId" --output text
Write-Host "Spot Fleet Request ID: $FleetId"

# ---- Step 2: Wait until an Instance ID is assigned ----
Write-Host "Waiting for instance to be assigned..."
do {
    Start-Sleep -Seconds 10
    $InstanceId = aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $FleetId --query "ActiveInstances[0].InstanceId" --output text
} while ($InstanceId -eq "None" -or [string]::IsNullOrEmpty($InstanceId))

Write-Host "Instance launched: $InstanceId"

# ---- Step 3: Get Public IP ----
do {
    Start-Sleep -Seconds 5
    $PublicIp = aws ec2 describe-instances --instance-ids $InstanceId --query "Reservations[0].Instances[0].PublicIpAddress" --output text
} while ([string]::IsNullOrEmpty($PublicIp) -or $PublicIp -eq "None")

Write-Host "Public IP: $PublicIp"

# ---- Step 4: Wait until SSH is reachable ----
Write-Host "Checking SSH availability on $PublicIp ..."
$sshReady = $false
do {
    try {
        $result = Test-NetConnection -ComputerName $PublicIp -Port 22 -WarningAction SilentlyContinue
        if ($result.TcpTestSucceeded) {
            $sshReady = $true
        } else {
            Start-Sleep -Seconds 5
        }
    } catch {
        Start-Sleep -Seconds 5
    }
} until ($sshReady)

Write-Host "✅ SSH is ready, connecting..."

# ---- Step 5: SSH into the instance ----
ssh -i $KeyFile "$User@$PublicIp"
