@echo off
setlocal enabledelayedexpansion

REM ---- Config ----
set JSON_FILE=spot_instance_request.json  REM Path to your JSON file
set KEY_FILE=KEY-FILE-PATH\KEY-FILE-NAME.pem  REM Path to your .pem file
set USER=ec2-user REM Amazon Linux = ec2-user | Ubuntu = ubuntu

REM ---- Step 1: Request Spot Fleet ----
for /f %%i in ('aws ec2 request-spot-fleet --spot-fleet-request-config file://%JSON_FILE% --query "SpotFleetRequestId" --output text') do set FLEET_ID=%%i
echo Spot Fleet Request ID: %FLEET_ID%

REM ---- Step 2: Wait until instance is running ----
echo Waiting for instance to launch...
:waitloop
for /f %%j in ('aws ec2 describe-spot-fleet-instances --spot-fleet-request-id %FLEET_ID% --query "ActiveInstances[0].InstanceId" --output text') do set INSTANCE_ID=%%j
if "%INSTANCE_ID%"=="None" (
    timeout /t 10 >nul
    goto waitloop
)
echo Instance launched: %INSTANCE_ID%

REM ---- Step 3: Get Public IP ----
for /f %%k in ('aws ec2 describe-instances --instance-ids %INSTANCE_ID% --query "Reservations[0].Instances[0].PublicIpAddress" --output text') do set PUBLIC_IP=%%k
echo Public IP: %PUBLIC_IP%

REM ---- Step 4: SSH into instance ----
ssh -i "%KEY_FILE%" %USER%@%PUBLIC_IP%
