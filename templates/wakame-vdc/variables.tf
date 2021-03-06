variable "global_network" {
  description = "Global Network ID to reach internet on Wakame-vdc"
  default = "nw-global"
}
variable "subnet_ids" {
  description = "Network ID which is created by common network pattern."
}
variable "shared_security_group" {
  description = "SecurityGroup ID which is created by common network pattern."
}
variable "wakame_key_id" {
  description = "ID of an existing KeyPair on wakame-vdc to enable SSH access to the instances."
}
variable "monitoring_image" {
  description = "[computed] MonitoringServer Image Id. This parameter is automatically filled by CloudConductor."
}
variable "monitoring_cpu_cores" {
  description = "MonitoringServer Cpu Cores"
  default = "1"
}
variable "monitoring_memory_size" {
  description = "MonitoringServer Memory Size"
  default = "2048"
}
