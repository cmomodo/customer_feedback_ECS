# CoderCo Assignment 1 - Open Source App Hosted on ECS with Terraform 🚀

This project is based on Customer Feedback App, an open source tool designed to facilitate customer feedback and improve customer experience. You can explore the tool's dashboard here: sign up

### Task/Assignment 📝

we were assigned to use one of the open source app avaialble and deploy it using terraform. The app i chosed was the cutomer feedback app. 

we will use a container image for the app, push it to ECR (recommended) or DockerHub. we will use a CI/CD pipeline to build, test, and push the container image.

Deploy the app on ECS using Terraform. All the resources should be provisioned using Terraform. Use TF modules.

The app is live on https://ceedev.co.uk/_health or https://ceedev.co.uk/signup

## System Design
![System Design Diagram](./images/ecs_p1.png)



## structure 
```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── modules/
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

## build app
terraform init

terraform plan 

terraform apply

## Health check confirmation 
![Health Check Confirmation](./images/health_check.png)
