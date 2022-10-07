
data "aws_iam_role" "eks_role" {
  name = "EKS_cluster1_role"
}

data "aws_iam_role" "node_group_role" {
  name = "AmazonEKSNodeRole"
}

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = data.aws_iam_role.eks_role.name
# }

# # Optionally, enable Security Groups for Pods
# # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
# resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = data.aws_iam_role.eks_role.name
# }

resource "aws_eks_cluster" "example" {
  name     = "OleksandrHavron-cluster"
  role_arn = data.aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }

  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region eu-central-1 --cluster ${self.name} --approve"
  }

  lifecycle {
    ignore_changes = all
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  # depends_on = [
  #   aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  #   aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  # ]
}

resource "aws_eks_node_group" "node_group1" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "node_group1"
  node_role_arn   = data.aws_iam_role.node_group_role.arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  # # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  # depends_on = [
  #   aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
  #   aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
  #   aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  # ]
}

# resource "aws_eks_identity_provider_config" "example" {
#   cluster_name = aws_eks_cluster.example.name

#   oidc {
#     client_id                     = aws_eks_cluster.example.identity[0].oidc[0].issuer
#     identity_provider_config_name = "example"
#     issuer_url                    = aws_eks_cluster.example.identity[0].oidc[0].issuer
#   }
# }

data "tls_certificate" "example" {
  url = aws_eks_cluster.example.identity[0].oidc[0].issuer
}

# resource "aws_iam_openid_connect_provider" "default" {
#   url = aws_eks_cluster.example.identity[0].oidc[0].issuer

#   client_id_list = ["sts.amazonaws.com"]

#   thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
# }

resource "aws_iam_role" "test_role" {
  name = "eksctl-OleksandrHavron-cluster-addon-iamserv-Role1"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.external_dns_policy.arn,]
  tags = {
    "alpha.eksctl.io/cluster-name"                  = aws_eks_cluster.example.name
    "alpha.eksctl.io/eksctl-version"                = "0.112.0"
    "alpha.eksctl.io/iamserviceaccount-name"        = "app/external-dns"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name"   = aws_eks_cluster.example.name
  }
}

resource "aws_iam_role" "loadbalancer_controller" {
  name = "eksctl-OleksandrHavron-cluster-addon-iamserv-Role2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.policy.arn,]

  tags = {
    "alpha.eksctl.io/cluster-name"                  = aws_eks_cluster.example.name
    "alpha.eksctl.io/eksctl-version "               = "0.112.0"
    "alpha.eksctl.io/iamserviceaccount-name"        = "kube-system/aws-load-balancer-controller"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name"   = aws_eks_cluster.example.name
  }
}
