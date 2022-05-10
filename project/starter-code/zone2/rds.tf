 module "project_rds_s" {
   source                  = "../zone2/modules/rds-s"
   primary_db_cluster_arn  = data.terraform_remote_state.db.outputs.db_p_arn
#   providers = {
#     aws = aws.usw1
#   }
   private_subnet_ids = module.vpc_west.private_subnet_ids
   vpc_id = module.vpc_west.vpc_id
 }