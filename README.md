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

## ✅ Prerequisites

Before running the scripts, ensure you have the following setup in your AWS environment:

1. **VPC with at least 3 Public Subnets**  
   - The Spot Fleet JSON uses multiple subnets for capacity optimization.  
   - Ensure these subnets are public (with an Internet Gateway attached and route to `0.0.0.0/0`).

2. **Security Group**  
   - Must allow the following inbound rules:
     - **TCP 22** → SSH access
     - **TCP 8080** → Jenkins web interface
     - (Optional) **0.0.0.0/0** for general public access (limit by IP if possible for security).

3. **EC2 Key Pair**  
   - Generate or use an existing key pair (`.pem` file).  
   - Update its name in `spot_instance_request.json` under `KeyName`.  
   - Keep the `.pem` file safe as it’s required for SSH login.

4. **IAM Role for Spot Fleet**  
   - Create an IAM role named (or with permissions equivalent to) **`aws-ec2-spot-fleet-tagging-role`**.  
   - This role allows Spot Fleet to launch and tag instances on your behalf.  
   - Attach the managed policy **`AmazonEC2SpotFleetTaggingRole`**.

5. **AWS CLI Installed & Configured**  
   - Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).  
   - Configure it with your credentials:
     ```bash
     aws configure
     ```
   - If you don’t want to install locally, you can use **AWS CloudShell**.

6. **PowerShell (Windows) or Terminal (Linux/macOS)**  
   - The automation script (`launch-spotfleet.ps1`) is designed for PowerShell on Windows.  
   - Alternatively, you can manually run CLI commands from CloudShell or a Linux terminal.

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

---

## ⚡ Alternative: Run with Batch Script (Windows)

If you don’t want to use the PowerShell script (`launch-spotfleet.ps1`),  
you can use the included **`launch-spotfleet.bat`** file instead.

The `.bat` script automates the same process:  
- Submits the Spot Fleet request  
- Waits for instance assignment  
- Fetches the public IP  
- SSHs into the instance  

This is useful if you prefer sticking to the classic Windows Command Prompt.  

---

## 🙌 Ending Note

This project shows how AWS Spot Instances can be turned into a **cost-effective DevOps playground**,  
where automation takes care of the heavy lifting.  

Whether you use **PowerShell** or **Batch scripts**, the end goal is the same:  
launch a ready-to-use EC2 Spot instance running **Docker and Jenkins**, in just a few minutes.  

Happy building 🚀  
