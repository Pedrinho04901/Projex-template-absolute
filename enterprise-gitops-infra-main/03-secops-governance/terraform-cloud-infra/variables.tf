variable "aws_region" {
  description = "Regi?o da AWS para o deploy da Fintech"
  type        = string
  default     = "sa-east-1"
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "Nome do cluster EKS principal da Projex"
  type        = string
  default     = "projex-fintech-eks"
}
