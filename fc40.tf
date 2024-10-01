data "ct_config" "fc40_ignition" {
  strict = true
  content = templatefile("butane/fc40.yaml.tftpl", {
    ssh_admin_username   = "core"
    ssh_admin_public_key = "${file("~/.ssh/id_ed25519.pub")}"
    hostname             = "fc40b"
  })
}

resource "proxmox_virtual_environment_vm" "fc40" {
  node_name   = "deb11phi"
  name        = "fc40a"
  description = "Managed by OpenTofu"

  machine = "q35"

  # Since we're installing the guest agent in our Butane config,
  # we should enable it here for better integration with Proxmox
  agent {
    enabled = true
  }

  memory {
    dedicated = 2048
  }

  # Here we're referencing the file we uploaded before. Proxmox will
  # clone a new disk from it with the size we're defining.
  disk {
    interface    = "virtio0"
    datastore_id = "data"
    file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
    size         = 16
  }

  # We need a network connection so that we can install the guest agent
  network_device {
    bridge = "vmbr0"
  }

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.fc40_ignition.rendered, ",", ",,")}'"
}
