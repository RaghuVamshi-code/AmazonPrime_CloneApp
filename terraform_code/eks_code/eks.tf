module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  # 1. Keeps your current VS Code terminal admin access working
  enable_cluster_creator_admin_permissions = true

  # 2. Grant cluster admin permissions to your Jenkins IAM User
  access_entries = {
    jenkins_pipeline_user = {
      # FIXME: Replace 'your-jenkins-iam-username' with your actual AWS IAM user name
      principal_arn     = "arn:aws:iam::442147575320:user/devops"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    # ADD THIS: Entry for your Root User Browser Session
    root_user = {
      principal_arn     = "arn:aws:iam::442147575320:root"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  eks_managed_node_groups = {
    panda-node = {
      min_size     = 2
      max_size     = 4
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "Panda_Node"
      }
    }
  }

  tags = local.tags
}
