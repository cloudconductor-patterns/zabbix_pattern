variable "subnet_ids" {
  description = "Subnet ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "shared_security_group_name" {
  description = "SecurityGroup name which is created by common network pattern."
}
variable "key_name" {
  description = "Name of an existing EC2/OpenStack KeyPair to enable SSH access to the instances."
}
variable "environment_id" {
  description = "[computed] Environment Id to avoid duplicate on Security group. This parameter is automatically filled by CloudConductor."
}
variable "monitoring_image" {
  description = "[computed] MonitoringServer Image Id. This parameter is automatically filled by CloudConductor."
}
variable "monitoring_instance_type" {
  description = "MonitoringServer instance type"
  default = "t2.small"
}
