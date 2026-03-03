# envs/dev — konfiguracja środowiska dev
# W06-T03: moduł network-core
# W07-T02: moduł network-endpoints

provider "aws" {
  region = var.region
}

module "network_core" {
  source = "../../modules/network-core"

  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  name_prefix          = "orderflow-dev"
  enable_nat_gateway   = true
  tags                 = {}
}

module "network_endpoints" {
  source = "../../modules/network-endpoints"

  vpc_id                 = module.network_core.vpc_id
  private_route_table_id = module.network_core.private_route_table_id
  private_subnet_ids     = module.network_core.private_subnet_ids
  sg_app_id              = module.network_core.sg_ecs_id

  name_prefix = "orderflow-dev"
  tags        = {}
}

