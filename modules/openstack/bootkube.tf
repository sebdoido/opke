# Self-hosted Kubernetes assets (kubeconfig, manifests)

module "bootkube" {
  source = "../bootkube"

  cluster_name          = "${var.cluster_name}"
  api_servers           = ["${format("%s.%s", var.cluster_name, var.openstack_dns_zone)}"]
  etcd_servers          = ["${data.template_file.etcd_hostname.*.rendered}"]
  etcd_ca               = "${module.etcd.ca_cert}"
  etcd_client_cert      = "${module.etcd.client_cert}"
  etcd_client_key       = "${module.etcd.client_key}"
  asset_dir             = "${var.asset_dir}"
  networking            = "${var.networking}"
  network_mtu           = "${var.network_mtu}"
  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  cloud_provider        = "openstack"
  cloud_config          = "/etc/kubernetes/cloud-config"
  versions              = {
    calico           = "v3.0.4"
    calico_cni       = "v2.0.1"
    flannel          = "v0.10.0-amd64"
    flannel_cni      = "v0.3.0"
    hyperkube        = "${var.kubernetes_version}"
    kubedns          = "1.14.8"
    kubedns_dnsmasq  = "1.14.8"
    kubedns_sidecar  = "1.14.8"
    pod_checkpointer = "3cd08279c564e95c8b42a0b97c073522d4a6b965"
  }
}
