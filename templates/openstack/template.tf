resource "openstack_compute_floatingip_v2" "main" {
  pool = "public"
}

resource "openstack_compute_secgroup_v2" "monitoring_security_group" {
  name = "MonitoringSecurityGroup${var.environment_id}"
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
  name = "MonitoringServer"
  image_id = "${var.monitoring_image}"
  flavor_name = "${var.monitoring_instance_type}"
  metadata {
    Role = "monitoring"
    Name = "MonitoringServer"
  }
  key_pair = "${var.key_name}"
  security_groups = ["${openstack_compute_secgroup_v2.monitoring_security_group.name}", "${var.shared_security_group_name}"]
  floating_ip = "${openstack_compute_floatingip_v2.main.address}"
  network {
    uuid = "${element(split(", ", var.subnet_ids), 0)}"
  }
}

output "cluster_addresses" {
  value = "${openstack_compute_instance_v2.monitoring_server.network.0.fixed_ip_v4}"
}

output "consul_addresses" {
  value = "${openstack_compute_floatingip_v2.main.address}"
}
