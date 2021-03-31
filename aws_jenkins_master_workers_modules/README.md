# Infrastructure as Code Example

TODO list:
- [x] The final touch would be to introduce infrastructure automation testing with terratest, so reorganise the project a little to accommodate that. Ideally we want to run the test from a docker container like I've seen here https://github.com/mineiros-io/terraform-aws-route53
- [x] Refactor the aws-peered-vpc module so we don't use hardcoded values for cidr blocks.
- [x] Another interesting test for modularity is use for_each and count blocks to create subnets dynamically. I want to pass as an input a list of subnet cidr blocks and the terraform script should automatically recognise the number of subnets to be created and spread them across availability zones
- [x] Introduce test automation for the moduled vpc peering creation and try change the number of subnets to test they are created correctly
- [x] Refactor the two modules for Jenkins master and worker nodes and create a single module that can provision both, master and worker nodes. Same principle applies as the VPC subnets, it should automatically provision the required number of workers. **Hint: use ${path.module} to reference files in the current module directory**
- [ ] Create a new module to deploy a bastion server and remove public access from the launch configuration
- [ ] Configure Jenkins master node for high availabiliy. This is a very large item:
  - [ ] For high availability the jenkins workers should be on an autoscaling group spread across multiple availability zones
  - [x] For this reason we have to change the provisioning method from push (local-exec) to pull (cloud-init that pulls and execute ansible script)
  - [ ] For high availability we can't afford to lose data from the master node, configure and mount block storage into the jenkins master so a new node can resume operations as soon as it's online
  - [ ] Can a backup strategy be configured from terraform? Define how you would backup and recover data data in the block storage volume in case something goes wrong
  - [ ] backup idea: take automatic snapshot of the EBS volume hosting the jenkins_home directory. Use a plugin or native AWS to store that data into an s3 bucket so you can even restore data from with ansible if you ever need to recreate the instance
  - [ ] The ansible playbook to setup master node should receive an optional input parameter with the name of the repository from where to pull the initial Jenkins configuration
  - [ ] Security: find out how to use EKS or some other service to automatically rotate credentials to access jenkins: 1. ssh keypairs 2. admin master password if it can be rotated automatically