## Configure the vSphere Provider
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# Define Datacenter
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

# Define esxi host/s
data "vsphere_host" "h1" {
    name = "myesxi1"
    datacenter_id = data.vsphere_datacenter.dc.id
}

# Define datastore
data "vsphere_datastore" "datastore" {
  name          = "datastore2"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define resource pool
data "vsphere_resource_pool" "pool" {
  name          = "cluster1/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define network
data "vsphere_network" "mgmt_lan" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define virtual switch
resource "vsphere_host_virtual_switch" "hvs1" {
   name = "vSwitch0"
   mtu = 9000
   host_system_id = data.vsphere_host.h1.id
   network_adapters = ["vmnic0"]
   active_nics = ["vmnic0"]
   standby_nics = ["vmnic0"]
}

# Define port group 1
resource "vsphere_host_port_group" "p1" {
    name = "VMK-iSCSI-vl-${var.iscsi_vlan1}"
    virtual_switch_name = vsphere_host_virtual_switch.hvs1.name
    host_system_id = data.vsphere_host.h1.id
    vlan_id = var.iscsi_vlan1
}

# Define port group 2
resource "vsphere_host_port_group" "p2" {
    name = "VMK-iSCSI-vl-${var.iscsi_vlan2}"
    virtual_switch_name = vsphere_host_virtual_switch.hvs1.name
    host_system_id = data.vsphere_host.h1.id
    vlan_id = var.iscsi_vlan2
}

# Define vmkernel adapter1
resource "vsphere_vnic" "vmk1" {
  host = data.vsphere_host.h1.id
  portgroup = vsphere_host_port_group.p1.name
  mtu = 9000
  ipv4 {
    dhcp = true
  }
} 

# Define vmkernel adapter2
resource "vsphere_vnic" "vmk2" {
  host = data.vsphere_host.h1.id
  portgroup = vsphere_host_port_group.p2.name
  mtu = 9000
  ipv4 {
    dhcp = true
  }
} 

# # Create Virtual Machine
# resource "vsphere_virtual_machine" "testvm" {
#   name             = "terraform-testvm"
#   resource_pool_id = data.vsphere_resource_pool.pool.id
#   datastore_id     = data.vsphere_datastore.datastore.id
#   num_cpus         = 1
#   memory           = 1024
#   guest_id         = "centos7_64Guest"
#   network_interface {
#     network_id   = data.vsphere_network.mgmt_lan.id
#     adapter_type = "vmxnet3"
#   }
#   disk {
#     size             = 5
#     label             = "terraform-testvm.vmdk"
#     eagerly_scrub    = false
#     thin_provisioned = true
#   }
# }