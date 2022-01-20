## Configure the vSphere Provider
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# Create Datacenter
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

# Create datastore
data "vsphere_datastore" "datastore" {
  name          = datastore2
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create resource pool
data "vsphere_resource_pool" "pool" {
  name          = "cluster1/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create network
data "vsphere_network" "mgmt_lan" {
  name          = "VM_VLAN1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create Virtual Machine
resource "vsphere_virtual_machine" "testvm" {
  name             = "terraform-testvm"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "debian11"
  network_interface {
    network_id   = data.vsphere_network.mgmt_lan.id
    adapter_type = "vmxnet3"
  }
  disk {
    size             = 5
    name             = "terraform-testvm.vmdk"
    eagerly_scrub    = false
    thin_provisioned = true
  }
}