resource "null_resource" "coreos_qcow2" {
  provisioner "local-exec" {
  #  command = "mv $(podman run --rm -v .:/data -w /data quay.io/coreos/coreos-installer:release download -s stable -a $(uname -m) -p qemu -f qcow2.xz -d) fedora-coreos.qcow2.img"
    command = "echo fedora-coreos.qcow2.img downloaded manually"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f fedora-coreos.qcow2.img"
  }
}

resource "proxmox_virtual_environment_file" "coreos_qcow2" {
  content_type = "iso"
  datastore_id = "data"
  node_name    = "deb11phi"

  depends_on = [null_resource.coreos_qcow2]

  source_file {
    path = "fedora-coreos.qcow2.img"
  }
}
