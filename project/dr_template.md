# Infrastructure

## AWS Zones
The primary zone we are working on is us-east-2. The secondary zone (zone2) is us-west-1. We also might use us-east-1 to monitor the database replication logs if we used this approach

## Servers and Clusters
- One EC2 instance in each region
- SSH key for accessing the EC2 instance
- Two RDS Clusters with one instance
- One EKS cluster with also one instance, autoscaling implemented
- GitHub repo for storing the Terraform code
- Load balancer for the website
- Monitoring platform (Grafana and Prometheus) for the web application deployed on K8s
- Two S3 buckets for the different regions

### Table 1.1 Summary
| Asset | Purpose                 | Size                                                           | Qty                                    | DR                                                                                                           |
|-------|-------------------------|----------------------------------------------------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------------|
| One EC2 instance | Server which runs the application | t3.micro                                                       | One node                               | This will be deployed on a second region                                                                     |----|
| SSH key for accessing the EC2 instance | Access to the EC2 in a secure way | not applicable                                                 | one per person                         | A new key has to be created in the secondary regions, since keys are not cross-regional                      |----|
| Two RDS Clusters with one instance | Store the data of the application | db.t2.small                                                    | up to two                              | A second cluster will be created in the secondary region                                                     |----|
| EKS cluster | Run the monitoring deployment | t3.medium                                                      | one (autoscaling active)               | This one cluster could monitor both regions                                                                  |----|
| GitHub repo | Save the terraform code |                                                                |                                        | not need to replicate                                                                                        |----|
| Monitoring platform | Deployment on k8s to monitor the application | Depending on the resources needed (horizontal pod autoscaling) | At least three replicas per deployment |----|

### Descriptions
- EC2 instance: hosts the application. There is one in each region. The secondary one is stopped and is going to be started in case that the primary one fails (warm deployment)
- SSH key: for accessing the EC2 instance. The keys are always created from the beginning on both regions
- Two RDS Clusters with one instance: Stores the data of the application. The secondary one will be replicated by making use of Cross-Region Replication: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Replication.CrossRegion.html
- One EKS cluster with also one instance, autoscaling implemented. This is high available by default (at least the master node). One for both regions may be enough for the first release.
- GitHub repo for storing the Terraform code.
- Load balancer for the website. There is a LoadBalancer in each region (the one in the secondary region is not deployed until needed), since this is not cross-regional. We will use Route53 with failover policy to point to the load balancers of each region
- Monitoring platform (Grafana and Prometheus) for the web application deployed on K8s. As stated on the EKS, there is only in one region, but inside the cluster there will be at least 3 pods with a self-healing mechanism
- Two S3 buckets for the different regions: To separate the projects in each region. Each of the is highly available and durable by design.

## DR Plan
### Pre-Steps:
- There is a stopped EC2 instance in the secondary region
- The ssh needed to access the instance is already in place (needed for the creation of the EC2)
- The load balancer is not in place, it will be deployed
- RDS cluster running as replica of the other region

## Steps:
- Start the EC2 in the other region
- Deploy the LoadBalancer in the secondary region
- When the EC2 is running and the LoadBalancer is deployed there is a failover in Route53. The new Request are prepared to be received
- Perform a failover on the RDS cluster to set the database in the new region as ready.
