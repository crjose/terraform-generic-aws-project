# Arquivo com a definição das variáveis. O arquivo poderia ter qualquer outro nome, ex. valores.tf

variable "regiao" {
  description = "Região da AWS para provisionamento"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile com as credenciais criadas no IAM"
  type = string
  default = "ricardoteixcloud"
}

variable "tag-base" {
  description = "Nome utilizado para nomenclaruras no projeto"
  type        = string
  default     = "ct_oficina"
}

# EC2

variable "ec2-tipo-instancia" {
  description = "Tipo da instância do EC2"
  type        = string
  default     = "t2.micro" # 2 vCPU, 1 GB
}

variable "ec2-chave-instancia" {
  description = "Nome da chave para acesso SSH"
  type        = string
  default     = "chave_especializacao"
}

variable "ec2-tamanho-ebs" {
  description = "Tamanho do disco"
  type        = number
  default     = 8
}

variable "arquivo-user-data" {
  description = "Script que será executado ao subir a instância"
  type        = string
  default     = "projeto_user_data.sh"
}

variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/info.php"
      "port"     = "80"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}

# RDS

variable "rds-identificador" {
  description = "Tipo da instância do RDS"
  type        = string
  default     = "ct-oficina"
}

variable "rds-tipo-instancia" {
  description = "Tipo da instância do RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds-nome-banco" {
  description = "Nome do schema criado inicialmente para usar no Projeto"
  type        = string
  default     = "oficinadb"
}

variable "rds-nome-usuario" {
  description = "Nome do usuário administrador da instância RDS"
  type        = string
  
  # default     = "nao colocar valor padrão aqui" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

variable "rds-senha-usuario" {
  description = "Senha do usuário administrador da instância RDS"
  type        = string

  # default     = "nao colocar valor padrão aqui" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

# SNS

variable "sns-email" {
  description = "Email para registrar no tópino SNS e enviar mensagens sobre a infra"
  type = string
  # default = "" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

# S3

variable "nome-bucket" {
  description = "Nome do bucket para configurar no Projeto"
  type = string
  default = "ct-oficina-files-op5"  # Como o bucket deve ser unico em toda a AWS, sugiro modifica este nome para evitar conflito.
}

variable "domain" {
  description = "Nome do domínio utilizado para a implantação"
  type = string
  default = "https://www.domain.com"
}

variable "route53-zone" {
  description = "ID da zona do domínio no Route 53"
  type = string
}