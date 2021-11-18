############################################################################
# resources needed for creating the vms
############################################################################

// service account for a couchbase cluster
resource "google_service_account" "couchbase_vm_sa" {
  account_id   = "${var.name_prefix}-couchbase-vm"
  display_name = "Couchbase VM Service Account"
  project      = var.project_id
}

// all nodes use this to wait 30 seconds after the initial node is spun up
resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.init_node]

  create_duration = "30s"
}

//  template file to render adding data, query node script to run at vm start up
data "template_file" "add_data_nodes" {
  template = file("${path.module}/startup_scripts/add-data-nodes.sh")
  vars = {
    cluster_node_ip = "${google_compute_instance.init_node.network_interface.0.network_ip}"
  }

  depends_on = [google_compute_instance.init_node]
}

//  template file to render adding index, search node script to run at vm start up
data "template_file" "add_index_nodes" {
  template = file("${path.module}/startup_scripts/add-index-nodes.sh")
  vars = {
    cluster_node_ip = "${google_compute_instance.init_node.network_interface.0.network_ip}"
  }

  depends_on = [google_compute_instance.init_node]
}

// randomly pick a zone from the region 
data "google_compute_zones" "available" {
  project = var.project_id
}



###############################################################################
# initial node of the cluster, or node 1,  later nodes are added to the cluster
# specifying this node's ip in shell scripts
###############################################################################

// the init node has data and query service,  it's a init node as in cluster is  
// initialized on this node
resource "google_compute_instance" "init_node" {
  name                = "${var.name_prefix}-couchbase-init-node"
  machine_type        = var.machine_type
  deletion_protection = var.del_protect

  // pick a zone for init node, spread out zones for all the rest nodes
  zone = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.disk_type
      size  = var.disk_size
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet

    // this empty block gives a ephemeral external ip
    access_config {}
  }

  // start up script when vm is booting up
  metadata_startup_script = file("${path.module}/startup_scripts/init-couchbase.sh")

  service_account {
    email  = google_service_account.couchbase_vm_sa.email
    scopes = ["cloud-platform"]
  }

}


resource "google_compute_instance" "data_node" {
  // create this many more data nodes, as init node is also a data node
  count               = var.data_node_count - 1
  deletion_protection = var.del_protect

  // add 1 becasue index starts with 0, naming starts from 1
  name         = "${var.name_prefix}-couchbase-data-${count.index + 1}"
  machine_type = var.machine_type

  // spread out same couchbase service type to different zones
  zone = data.google_compute_zones.available.names["${count.index}" % length(data.google_compute_zones.available.names)]

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.disk_type
      size  = var.disk_size
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet

    // this empty block gives a ephemeral external ip
    access_config {}
  }
  // start up script when vm is booting up, use add data node script from data source
  metadata_startup_script = data.template_file.add_data_nodes.rendered

  service_account {
    email  = google_service_account.couchbase_vm_sa.email
    scopes = ["cloud-platform"]
  }

  // data node one needs to be ready for nodes to be added to cluster
  depends_on = [google_compute_instance.init_node, time_sleep.wait_30_seconds]
}



// create nodes for index and search servies
resource "google_compute_instance" "index_node" {

  // creates this many index nodes
  count               = var.index_node_count
  deletion_protection = var.del_protect

  // add 1 because index starts with 0, naming starts with 1
  name         = "${var.name_prefix}-couchbase-index-${count.index + 1}"
  machine_type = var.machine_type

  // spread out same couchbase service type to different zones
  zone = data.google_compute_zones.available.names["${count.index}" % length(data.google_compute_zones.available.names)]

  boot_disk {
    initialize_params {
      image = var.image
      type  = var.disk_type
      size  = var.disk_size
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet

    // this empty block gives a ephemeral external ip
    access_config {}
  }
  // start up script when vm is booting up, use template file that has ips of node 1
  metadata_startup_script = data.template_file.add_index_nodes.rendered

  service_account {
    email  = google_service_account.couchbase_vm_sa.email
    scopes = ["cloud-platform"]
  }

  // data node one needs to be ready for nodes to be added to cluster
  depends_on = [google_compute_instance.init_node, time_sleep.wait_30_seconds]
}


####################################################################
# creates a cloud storage bucket to store no data cb buckets
# and give both stg and new prd cluster IAM access to it
####################################################################

## client staging cluster service account
## for demo can add this permission manually
resource "google_storage_bucket_iam_member" "staging_sa" {
  bucket = google_storage_bucket.cb_backup.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${var.cb_stg_sa}"
}

## give new prd couchbase cluster service account to bucket
resource "google_storage_bucket_iam_member" "prd_sa" {
  bucket = google_storage_bucket.cb_backup.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.couchbase_vm_sa.email}"
}


resource "google_storage_bucket" "cb_backup" {
  name          = var.bucket_name
  location      = "region_name"
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
