variable "key_name" {}
variable "monitoring_image" {}
variable "monitoring_instance_type" {}
variable "monitoring_server_size" {}

resource "openstack_compute_floatingip_v2" "main" {
  count = "${var.monitoring_server_size}"
  pool = "public"
}

resource "openstack_compute_secgroup_v2" "monitoring_security_group" {
  name = "MonitoringSecurityGroup"
  description = "Enable HTTP access via port 80, Zabbix-agent access"
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 10051
    to_port = 10051
    ip_protocol = "tcp"
    cidr = "10.0.0.0/16"
  }
}

resource "openstack_compute_instance_v2" "monitoring_server" {
  count = "${var.monitoring_server_size}"
  name = "MonitoringServer"
  image_id = "${var.monitoring_image}"
  flavor_name = "${var.monitoring_instance_type}"
  metadata {
    Role = "monitoring"
    Name = "MonitoringServer"
  }
  key_pair = "${var.key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.monitoring_security_group.name}", "${var.shared_security_group}"]
  floating_ip = "${element(openstack_compute_floatingip_v2.main.*.address, count.index)}"
  network {
    uuid = "${element(split(", ", var.network_id), count.index)}"
  }
}

output "cluster_addresses" {
  value = "${join(", ", openstack_compute_instance_v2.monitoring_server.*.network.0.fixed_ip_v4)}"
}

output "frontend_addresses" {
  value = "${join(", ", openstack_compute_floatingip_v2.main.*.address)}"
}
