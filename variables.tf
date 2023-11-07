variable "region" {
  default = "us-west-2"
}

variable "public_availability_zones" {
  type = list(string)
}

variable "subnet_names" {

  type = list(string)
}

variable "private_availability_zones" {
  type = list(string)

}
