resource "aws_eip" "monitoring_server_eip" {
  vpc = true
  instance = "${aws_instance.monitoring_server.id}"
}

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

resource "aws_security_group_rule" "shared_security_group_inbound_rule_zabbix" {
    type = "ingress"
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    security_group_id = "${var.shared_security_group}"
    source_security_group_id = "${aws_security_group.monitoring_security_group.id}"
}

resource "aws_instance" "monitoring_server" {
  ami = "${var.monitoring_image}"
  instance_type = "${var.monitoring_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.monitoring_security_group.id}", "${var.shared_security_group}"]
  subnet_id = "${element(split(", ", var.subnet_ids), 0)}"
  associate_public_ip_address = true
  tags {
    Name = "MonitoringServer"
  }
}

output "cluster_addresses" {
  value = "${aws_instance.monitoring_server.private_ip}"
}

output "consul_addresses" {
  value = "${aws_eip.monitoring_server_eip.public_ip}"
}
