# Provisionning OpenStack instances using Terraform
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.49.0"
    }
  }
}

# Defining the provider
provider "openstack" {
  user_name   = "admin"
  password    = "x"
  tenant_name = "admin"
  auth_url    = "http://192.168.10.208:5000/v3"
  region      = "RegionOne"
}

# Defining the variables
variable "instance_name" {
  default = "node"
}

variable "boot_volume_id" {
  default = ["b9e0c592-083c-4453-afe8-9d2f38a0477d", "07efefdb-0730-480e-8e91-cac5f2d3aac7"]
}

variable "network_name" {
  default = "selfservice"
}

# Creating the instances with the existing bootable volumes
resource "openstack_compute_instance_v2" "k8s_instance" {
  count           = length(var.boot_volume_id)
  name            = "${var.instance_name}-${count.index}"
  flavor_name     = "m2.huh"
  key_pair        = "k8s_key"
  security_groups = ["default"]

  block_device {
    uuid             = var.boot_volume_id[count.index]
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  network {
    name = var.network_name
  }

  # Specify cloud-init configuration
  user_data = <<-EOF
    #cloud-config
    password: x
    chpasswd: { expire: False }
    ssh_pwauth: True
  EOF
}

# Create floating IPs
resource "openstack_networking_floatingip_v2" "floating_ip" {
  count = length(openstack_compute_instance_v2.k8s_instance)
  pool  = "provider"
}

# Associate floating IPs with the instances
resource "openstack_compute_floatingip_associate_v2" "associate_floating_ip" {
  count       = length(openstack_compute_instance_v2.k8s_instance)
  floating_ip = openstack_networking_floatingip_v2.floating_ip[count.index].address
  instance_id = openstack_compute_instance_v2.k8s_instance[count.index].id
  depends_on  = [openstack_compute_instance_v2.k8s_instance]
}
