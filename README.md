# Terraform VPC

- Creating VPC network within AWS Console Using terraform 
- This architecture contains one VPC in single Availability Zone,
- There is one Public and one Private Subnet within

## VPC
- It contains the subnet range of 10.0.0.0./16

### Public Subnet 
- It has subnet range of 10.0.0.0/24 
- Contains one EC2 Application serverrunning PHP 

### Private Subnet 
- It has subnet range of 10.0.2.23/24 

It is later verfified using ``output.tf``

![VPC](./images/Final-arc.png)