# Ingress Controller Setup Steps:
# 1. Create IAM role and service account for AWS Load Balancer Controller
# 2. Install AWS Load Balancer Controller using Helm or kubectl
# 3. Configure ingress resources to use the controller
# 4. Set up SSL/TLS certificates (optional)
# 5. Configure DNS routing to the load balancer

module "ingres" {
  source            = "../../modules/eks/esssentials"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id

  depends_on = [module.eks]
}
