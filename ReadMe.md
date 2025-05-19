# Web Application Deployment using Terraform on AWS

This repository contains a Terraform configuration that provisions a basic infrastructure on AWS for deploying a simple web application using Apache. The infrastructure includes a VPC, subnets, a security group, an EC2 instance running Apache, and an Application Load Balancer (ALB) with a target group.

##  **Overview**

The goal of this setup is to deploy a basic Apache web server and make it accessible via an Application Load Balancer. This setup is intended for testing and learning purposes. The infrastructure consists of the following components:

* **VPC:** A Virtual Private Cloud with two public subnets.
* **Internet Gateway:** To provide internet access to the subnets.
* **Route Table:** Routes internet traffic to the subnets.
* **Security Group:** Allows HTTP (port 80) and SSH (port 22) access.
* **EC2 Instance:** Runs Apache and serves a simple webpage.
* **Load Balancer:** An ALB that distributes traffic to the Apache server.
* **Target Group:** Registers the EC2 instance and routes traffic to port 80.

---

##  **Directory Structure**

```
├── main.tf                # Main infrastructure configuration
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
└── terraform.tfvars       # Variable values (excluded from version control)
```

---

##  **Getting Started**

### **1. Prerequisites**

* AWS account and IAM credentials with sufficient permissions.
* Terraform installed ([Install Terraform](https://developer.hashicorp.com/terraform/downloads)).
* SSH key pair for accessing the EC2 instance.

---

### **2. Clone the Repository**

```bash
git clone <REPO_URL>
cd <REPO_DIRECTORY>
```

---

### **3. Configure AWS Credentials**

Set your AWS access key and secret key:

```bash
export AWS_ACCESS_KEY_ID="<YOUR_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<YOUR_SECRET_KEY>"
```

---

### **4. Modify `terraform.tfvars`**

Update the `terraform.tfvars` file with your desired configuration:

```hcl
aws_region = "us-east-1"
ami_id = "ami-0c7217cdde317cfec"
instance_type = "t2.micro"
webpage_content = "<h1>Hey - I Know you Love Destiny</h1><p>But if you are seing this you are stessing him out!</p>"
```

---

### **5. Initialize Terraform**

Run the initialization command to download the necessary providers and modules:

```bash
terraform init
```

---

### **6. Deploy the Infrastructure**

To review the changes that will be applied:

```bash
terraform plan
```

To apply the changes:

```bash
terraform apply
```

When prompted, type `yes` to confirm.

---

### **7. Access the Application**

After the deployment is complete, you can access the application using the outputs provided by Terraform:

* **EC2 Public IP:** Direct access to the Apache server.
* **Load Balancer DNS:** Access through the ALB.

```bash
echo "EC2 Instance IP: $(terraform output -raw ec2_instance_public_ip)"
echo "Load Balancer DNS: $(terraform output -raw load_balancer_dns)"
```

---

### **8. Outputs**

After deployment, Terraform will display the following information:

* **EC2 Public IP:** Directly access the web server.
* **Load Balancer DNS:** URL to access the application via the load balancer.
* **Instance ID:** Useful for debugging and SSH access.
* **Target Group ARN:** Reference to the target group in the ALB.
* **Security Group ID:** Security group managing the instance and ALB.
* **Key Pair Name:** SSH key pair for accessing the EC2 instance.

---

### **9. Cleanup**

To destroy all resources and avoid unnecessary AWS charges, run:

```bash
terraform destroy
```

---

###  **Important Considerations**

* Ensure that the security group allows inbound HTTP (port 80) and SSH (port 22) traffic.
* Verify that the AMI ID used is valid for the specified region (`us-east-1`).
* Monitor the target group health status to ensure the instance is registered and reachable.
* The ALB health check path is set to `/`. Ensure this path is accessible and responds with a `200 OK` status.

---

###  **License**

This project is for educational purposes only. Feel free to modify and experiment with it.

---

###  **Author**

**Destiny Obueh** | DevOps Engineer | `iDeploy | iSecure | iSustain`

---
