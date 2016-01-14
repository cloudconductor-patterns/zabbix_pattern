variable "vpc_id" {
  description = "VPC ID which is created by common network pattern."
}
variable "subnet_ids" {
  description = "Subnet ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "key_name" {
  description = "Name of an existing EC2/OpenStack KeyPair to enable SSH access to the instances."
}
variable "monitoring_image" {
  description = "[computed] MonitoringServer Image Id. This parameter is automatically filled by CloudConductor."
}
variable "monitoring_instance_type" {
  description = "MonitoringServer instance type"
  default = "t2.small"
}
variable "monitoring_server_size" {
  description = "MonitoringServer instance size"
  default = "1"
}
