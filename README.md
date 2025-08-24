# 🚀 AWS EC2 Spot Fleet Automation

![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-Automation-blue?logo=powershell&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-Ready-red?logo=jenkins&logoColor=white)

---

## 📖 About this Project

This project demonstrates how to **automate the provisioning of AWS EC2 Spot Instances** using:  

- **Spot Fleet Requests** → to launch instances across multiple subnets with high availability.  
- **AWS CLI** → to request, describe, and manage fleets.  
- **PowerShell** → to automate the full lifecycle (launch, wait for instance, fetch public IP, SSH in).  
- **UserData scripts** → to bootstrap essential DevOps tools (Git, Docker, Jenkins) immediately on first boot.  

### 🔹 Why this project?  
- **Cost Optimization** → Spot Instances are up to 90% cheaper than On-Demand.  
- **Automation** → No manual setup; the instance is DevOps-ready in minutes.  
- **Hands-on DevOps Practice** → Demonstrates skills in AWS, Infrastructure as Code, automation scripting, and CI/CD setup.

---

## 📌 Files in this Repo

- **`spot_instance_request.json`** → Multi-subnet Spot Fleet configuration (place Base64 user-data in `"UserData"`).
- **`userdata.sh`** → Bootstrap script (Docker, Git, Docker Compose, Jenkins container).
- **`launch-spotfleet.ps1`** → PowerShell automation (request fleet → wait for instance → get public IP → wait for SSH → SSH).

---

## 🧭 Steps to Launch the Spot Instance

### 1) Fill in placeholders in `spot_instance_request.json`
Open `spot_instance_request.json` and replace:
- `<account-id>` → your AWS Account ID
- `ami-xxxxxxxx` → a valid AMI (e.g., Amazon Linux 2)
- `my-keypair` → your EC2 key pair name
- `subnet-aaa111`, `subnet-bbb222`, `subnet-ccc333` → your subnet IDs
- `sg-xxxxxx` → your security group ID (must allow **TCP 22** for SSH and **TCP 8080** for Jenkins UI)

> We’ll paste the Base64 of your `userdata.sh` into `"UserData"` in Step 2.

---

### 2) Convert `userdata.sh` to Base64 and paste into JSON

**Linux/macOS/WSL/CloudShell**

1. Run the below command in terminal:
```bash
base64 userdata.sh > userdata.txt
```
2. Open userdata.txt and copy its single-line Base64 content.
3. Paste the Base64 string into `spot_instance_request.json` in `UserData` section.

> **Note:** Base64 will differ if we modify `userdata.sh`. Always regenerate after edits.

---

### 3) Edit `launch-spotfleet.ps1` and update:
- `$JsonFile` → path to your `spot_instance_request.json`

- `$KeyFile` → path to your `.pem` key

- `$User` → `ec2-user` (Amazon Linux) or `ubuntu` (Ubuntu)

---

### 4) Run the file in powershell
```
.\launch-spotfleet.ps1
```

---

### The script will:

- Submit the Spot Fleet request (if not already submitted)

- Wait for an instance assignment

- Retrieve the instance Public IP

- Wait for SSH (22) to be reachable

- SSH into the instance automatically

---

### 5) Access Jenkins
1. Open the link in browser:
```
http://<Public-IP>:8080
```
2. Run the below command and copy initial admin password:
```
cat /var/log/user-data.log
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
1. Copy the Public IPv4 Address of the instance from EC2 console.
2. Open Cloudshell in AWS Console (You'll see the button in botton left and top bar >.)
3. Click 'Actions' on right side and select 'Upload File' option.
4. Upload the `spot_instance_request.json` file.
5. Run the below command:
```
aws ec2 request-spot-fleet --spot-fleet-request-config file://spot_instance_request.json
```
