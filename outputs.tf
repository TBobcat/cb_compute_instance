output "project_id" {
  description = "project for couchbase vm creation"
  value = google_compute_instance.init_node.project
}

## using var because boot disk is redacted by terraform
output "boot_disk" {
  description = "couchbase image for the vm"
  value = var.image
}

output "data_node_count" {
  description = "number of data nodes to spin up"
  value = var.data_node_count
}

output "index_node_count" {
  description = "number of data nodes to spin up"
  value = var.index_node_count
}

output "network" {
    description = "network the vm resides in"
    value = google_compute_instance.init_node.network_interface
}
