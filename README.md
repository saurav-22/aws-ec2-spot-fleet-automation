# AWS EC2 Spot Fleet Automation

![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-Automation-blue?logo=powershell&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-Ready-red?logo=jenkins&logoColor=white)

---

## About this Project

This project demonstrates how to **automate the provisioning of AWS EC2 Spot Instances** using:  

- **Spot Fleet Requests** -> to launch instances across multiple subnets with high availability.  
- **AWS CLI** -> to request, describe, and manage fleets.  
- **PowerShell/Batch/Bash** -> to automate the full lifecycle (launch, wait for instance, fetch public IP, SSH in).  
- **UserData script** -> to fetch script from S3 and bootstrap essential DevOps tools (Git, Docker, and Jenkins) immediately on first boot.

### Why this project?  
- **Cost Optimization** -> Spot Instances are up to 90% cheaper than On-Demand.  
- **Automation** -> No manual setup; the instance is DevOps-ready in minutes.  
- **Hands-on DevOps Practice** -> Demonstrates skills in AWS, Infrastructure as Code, automation scripting, and CI/CD setup.

---

## Files in this Repo

- **`spot_instance_request.json`** -> Multi-subnet Spot Fleet configuration 
- **`UserData.sh`** -> Bootstrap script (Fetch installation script from S3 to install Docker, Git, and Jenkins).
- **`packages-installation.sh`** -> Script to be uploaded on S3 to install Docker, Git, and Jenkins.
- **`launch-spotfleet.ps1`** -> PowerShell automation (request fleet -> wait for instance -> get public IP -> wait for SSH -> SSH).
- **`launch-spotfleet.bat`** -> PowerShell automation (request fleet -> wait for instance -> get public IP -> SSH).
- **`launch-spotfleet.sh`** -> PowerShell automation (request fleet -> wait for instance -> get public IP -> wait for SSH -> SSH).

---

## Prerequisites
1) AWS CLI Installed and Configured on your system.
    - Follow ![AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to do so.

2) S3 Bucket to store the `packages-installation.sh` script.
    - Go to AWS Management Console and search for S3.
    - Click on Create Bucket.
    - Select 'General Purpose' as Bucket Type.
    - Enter bucket name and click Create Bucket.
    - Now open the bucket.
    - Click on Upload button and upload `packages-installation.sh` file.
  
3) IAM Role for EC2 to access S3 bucket.
    - Go to AWS Management Console and search for IAM.
    - Click on Roles > Create Role.
    - Select 'AWS Service' in Trusted entity type option.
    - In the Use case drop down, select EC2 and click next.
    - Select `AmazonS3ReadOnlyAccess` policy.
    - Enter role name and click 'Create role' button.
  
4) Update `UserData.sh` script and get base64 encoded data
    - Open `UserData.sh` script.
    - Enter your bucket name in the placeholder `YOUR-BUCKET-NAME` and save.
    - If you're using Linux/macOS, then open the terminal and type:
      ```
      base64 -w 0 UserData.sh
      ```
    - If you're on Windows system, then open any 3rd party tool online to do so. ( ![Base64 Encode](https://www.base64encode.net/) )

---

## Steps to Launch the Spot Instance

### 1) Fill in placeholders in `spot_instance_request.json`
Open `spot_instance_request.json` and replace:
- `YOUR-ACCOUNT-ID` -> your AWS Account ID
- `ami-xxxxxxxx` -> a valid AMI (Currently its using Amazon Linux 2)
- `YOUR-KEY-PAIR-NAME` -> your EC2 key pair name
- `ENTER BASE64 ENCODED USER DATA SCRIPT` -> Base64 Encoded text
- `IamInstanceProfie` -> Instance Profile ARN of the IAM Role created.
- `YOUR-SUBNET-ID`, `YOUR-2nd-SUBNET-ID`, `YOUR-3rd-SUBNET-ID` -> your subnet IDs
- `YOUR-SECURITY-GROUP-ID` -> your security group ID (must allow **TCP 22** for SSH and **TCP 8080** for Jenkins UI)

---

### 3) Edit `launch-spotfleet.ps1` and update:
- `$JsonFile` -> path to your `spot_instance_request.json`

- `$KeyFile` -> path to your `.pem` key

- `$User` -> `ec2-user` (Amazon Linux) or `ubuntu` (Ubuntu)

**If you want to use the batch file or bash script, then update the same values accordingly.**

---

### 4) Run the file in: 

- Powershell
```
.\launch-spotfleet.ps1
```
  - NOTE - If you get any error in PowerShell saying running scripts is disabled on this system then launch Powershell as Administrator:
    - **Bypass policy for current session** - Type `Set-ExecutionPolicy Bypass -Scope Process` and hit Enter.
      
      OR
    - **Update Execution Policy for current user** - Type `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` and hit Enter.

- CMD
```
launch-spotfleet.bat
```
- Bash
```
chmod +x launch-spotfleet.sh
./launch-spotfleet.sh
```

---

### The script will:

- Submit the Spot Fleet request (if not already submitted)

- Wait for an instance assignment

- Run UserData script to install packages

- Retrieve the instance Public IP

- Wait for SSH (22) to be reachable (This will not work in case of batch file)

- SSH into the instance automatically

---

### 5) Access Jenkins
1. Open the link in browser:
```
http://<Public-IP>:8080
```
2. Run the below command and copy initial admin password:
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
3. Paste it in the password field in browser.
4. Install desired plugins.

---

### 6) Below are Cleanup commands to run after your work is done (to avoid charges)
1. Cancel fleet and terminate instances:
```
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids <sfr-xxxxxxx> --terminate-instances
```
2. Cancel fleet but keep instances running:
```
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids <sfr-xxxxxxx> --no-terminate-instances
```
3. Terminate instances manually:
```
aws ec2 terminate-instances --instance-ids <i-xxxxxxxx>
```

---

## You can also launch the spot fleet via cloudshell if you don't have AWS cli in your PC.
1. Open Cloudshell in AWS Console (You'll see the `>_` button in botton left and top bar)
2. Click 'Actions' on right side and select 'Upload File' option.
3. Upload the `spot_instance_request.json` file.
4. Run the below command:
```
aws ec2 request-spot-fleet --spot-fleet-request-config file://spot_instance_request.json
```
