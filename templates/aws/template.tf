variable "bootstrap_expect" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "shared_security_group" {}
variable "key_name" {}
variable "monitoring_image" {}
variable "monitoring_instance_type" {}
variable "monitoring_server_size" {}

resource "aws_security_group" "monitoring_security_group" {
  name = "MonitoringSecurityGroup"
  description = "Enable HTTP access via port 80, Zabbix-agent access"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 10051
    to_port = 10051
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_instance" "monitoring_server" {
  count = "${var.monitoring_server_size}"
  ami = "${var.monitoring_image}"
  instance_type = "${var.monitoring_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.monitoring_security_group.id}", "${var.shared_security_group}"]
  subnet_id = "${element(split(", ", var.subnet_id), count.index)}"
  associate_public_ip_address = true
  tags {
    Name = "MonitoringServer"
  }
}

output "cluster_addresses" {
  value = "${join(", ", aws_instance.monitoring_server.*.private_ip)}"
}

output "frontend_addresses" {
  value = "${join(", ", aws_instance.monitoring_server.*.public_ip)}"
}
