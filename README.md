
# Project: Multi-Tier Private Cloud with Bastion Host and Load Balancer

## Overview

This project establishes a secure and scalable cloud infrastructure on AWS using Terraform. It provisions a Virtual Private Cloud (VPC) with both public and private subnets and deploys essential components such as EC2 instances, a NAT Gateway, a Bastion Host, and Load Balancers to ensure high availability and fault tolerance.

## Components

1. **VPC (Virtual Private Cloud)**
   - Creates an isolated network for all resources.

2. **Subnets**
   - **Public Subnets:** Host the Bastion Host and public-facing resources.
   - **Private Subnets:** Host backend EC2 instances (e.g., Nginx servers) and remain isolated from direct internet access.

3. **Internet Gateway (IG)**
   - Connects the VPC to the internet for public subnets.

4. **NAT Gateway**
   - Provides outbound internet access for private instances while keeping them isolated from inbound traffic.

5. **Route Tables**
   - **Public Route Table:** Routes traffic from public subnets to the Internet Gateway.
   - **Private Route Table:** Routes traffic from private subnets to the NAT Gateway.

6. **Key Pair**
   - Creates an SSH key pair for secure access to the EC2 instances.

7. **Security Groups**
   - Configures firewall rules for various components, including the Bastion Host, private instances, and the Load Balancer.

8. **EC2 Instances**
   - **Public Instances (Bastion Hosts):** Serve as a secure entry point.
   - **Private Instances (Backend):** Host web servers (e.g., Nginx) that are not directly accessible from the internet.

9. **Load Balancers**
   - **Public Load Balancer:** Distributes external traffic.
   - **Private Load Balancer:** Routes traffic to private instances.

10. **Data Source**
    - Dynamically retrieves the latest Ubuntu AMI.

11. **Print IPs Module**
    - Uses remote provisioners to configure instances and a local-exec provisioner to print all IPs and the load balancer's DNS to a file (`all-ips.txt`).

## Architecture Diagram

![Architecture Diagram](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/3.png)

*The diagram represents the VPC with public and private subnets, NAT Gateway, Bastion Host, Load Balancers, and EC2 instances.*

## How to Connect

- **SSH to Bastion Host:**  
  Use the Bastion Host as a jump server to securely connect to private instances.
- **Access via Load Balancer:**  
  Use the public DNS of the Load Balancer to access your application.

## Benefits

- **Security:**  
  Private subnets and NAT Gateway protect backend resources from direct internet exposure.
- **Scalability:**  
  Modular architecture makes it easy to add or update components.
- **High Availability:**  
  Load Balancers and multi-AZ deployments ensure fault tolerance.
- **Manageability:**  
  A Bastion Host allows centralized, secure access to private instances.

## Getting Started

1. **Install Terraform:**  
   Download and install Terraform from [terraform.io](https://www.terraform.io/downloads).

2. **Configure AWS Credentials:**  
   Ensure your AWS credentials are set (using environment variables, AWS CLI, or IAM roles).

3. **Create a New Workspace:**  
   ```bash
   terraform workspace new dev
   ```

4. **Configure Remote Backend:**  
   Set up an S3 bucket and a DynamoDB table for Terraform state management. Update your `provider.tf` accordingly.

5. **Set Variables:**  
   Edit `terraform.tfvars` with your project-specific values (VPC CIDR, subnet configurations, AMI ID, instance type, etc.).

6. **Initialize Terraform:**  
   ```bash
   terraform init
   ```

7. **Plan the Deployment:**  
   ```bash
   terraform plan
   ```

8. **Deploy the Infrastructure:**  
   ```bash
   terraform apply
   ```

## Cleanup
To destroy all the resources created by Terraform:
```bash
terraform destroy -auto-approve
```

## Shots

Below are some key screenshots for this project:


- **a. Workspace Creation:**  
  Screenshot from creating and working on the `dev` workspace.
  
  ![Workspace Screenshot](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/1.png)
  
- **b. Proxy Configuration:**  
  Screenshot from the configuration of the proxy (or Apache configuration on instances).
  
  ![Proxy Configuration1](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/16.png)

  ![Proxy Configuration2](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/15.png)
  
- **c. Load Balancer Public DNS:**  
  Screenshot from the browser showing the public DNS of the Load Balancer returning the content of the private EC2 instances.
  
  ![Load Balancer DNS](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/10.png)

  ![Load Balancer DNS2](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/14.png)

  ![Load Balancer DNS3](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/13.png)
 
- **d. S3 State File:**  
  Screenshot from the S3 bucket showing the Terraform state file.
  
  ![S3 State](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/2.png)

  ![S3 State2](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/4.png)

  ![S3 State3](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/6.png)

  ![S3 State4](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/12.png)


- **e. Additional Shots:**  

![Shot5](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/5.png)

![Shot7](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/7.png)

![Shot8](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/8.png)

![Shot9](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/9.png)

![Shot11](https://github.com/mohamedesmael10/MultiTier_Terraform/blob/main/Screenshots/11.png)



## Project Structure

```
├── all-ips.txt
├── backend.tf
├── main.tf
├── modules
│   ├── data_source
│   ├── instance
│   ├── internet_gateway
│   ├── key_pair
│   ├── load_balancer
│   ├── nat_gateway
│   ├── print_ips
│   ├── route_table
│   ├── security_group
│   ├── subnet
│   └── vpc
├── outputs.tf
├── provider.tf
├── README.md
├── terraform.tfvars
├── variables.tf
└── web_page
```

## Conclusion

This project demonstrates how to build a robust, secure, and scalable cloud infrastructure on AWS using Terraform. By utilizing custom modules for VPC, Subnet, Internet Gateway, NAT Gateway, Route Tables, Security Groups, EC2 Instances, Load Balancers, and more, it delivers a multi-tier environment that isolates sensitive components while providing necessary access via a Bastion Host and Load Balancer.

Follow best practices for security, remote state management, and modular code organization to maintain and scale your infrastructure effectively.

- **Mohamed Mostafa Esmael**  
  Email: [mohamed.mostafa.esmael10@outlook.com](mailto:mohamed.mostafa.esmael10@outlook.com)  
  LinkedIn: [linkedin.com/in/mohamedesmael](https://linkedin.com/in/mohamedesmael)
