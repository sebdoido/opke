# worker

resource "openstack_compute_servergroup_v2" "worker_group" {
  name     = "${var.cluster_name}-worker"
  policies = ["anti-affinity"]
}


# Worker Container Linux Ignition
data "ignition_config" "worker-ignition" {
  count = "${var.worker_count}"
  files = [
    "${module.ignition-controller.kubelet-env}",
    "${module.ignition-controller.max-user-watches}",
    "${module.ignition-controller.kubeconfig}",
    "${module.ignition-controller.delete-node-file}",
    "${module.ignition-controller.cloud-ca}",
    "${module.ignition-controller.cloud-config}"
  ]
  systemd = [
    "${module.ignition-controller.delete-node-service}",
    "${module.ignition-controller.wait-for-dns}",
    "${module.ignition-controller.kubelet}",
    "${module.ignition-controller.update-ca-certs}",
    "${module.ignition-controller.docker}",
    "${module.ignition-controller.locksmithd}"
  ]
  users = [
    "${module.ignition-controller.core-user}",
  ]
}
resource "openstack_compute_instance_v2" "worker_node" {
  count = "${var.worker_count}"
  name  = "${var.cluster_name}-worker${count.index}"

  image_name = "${var.openstack_os_image_name}"
  image_id   = "${var.openstack_os_image_id}"

  flavor_name = "${var.openstack_worker_flavor_name}"
  flavor_id   = "${var.openstack_worker_flavor_id}"

  key_pair = "${var.cluster_name}_keypair"

  metadata {
    role = "worker"
  }

  network {
    port = "${openstack_networking_port_v2.worker.*.id[count.index]}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.worker_group.id}"
  }

  user_data    = "${element(data.ignition_config.worker-ignition.*.rendered,count.index)}"
  config_drive = true
}

resource "openstack_compute_floatingip_associate_v2" "worker" {
  count = "${var.worker_count}"

  floating_ip = "${openstack_networking_floatingip_v2.worker.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.worker_node.*.id[count.index]}"
}
