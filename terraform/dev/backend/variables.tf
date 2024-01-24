variable "aws_access_key" {
    type = string
    description = "Access key for AWS"
}

variable "aws_secret_key" {
    type = string
    description = "Secret key for AWS"
}

variable "subnet_count" {
    default = 1
}

variable "env_name" {
    default = "dev"
}

variable "network_address_space" {
    default = "10.0.0.0/16"
}
