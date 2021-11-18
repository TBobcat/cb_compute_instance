<!-- BEGIN_TF_DOCS -->
## Overview
This module is used to spin up a couchbase cluster on VMs on GCP. Node numbers are specified in module. 
The default credentials for admin. is user:Administrator, password:password

## How to
To use this module, create a `couchbase.tf` like the example below.

Example of using this module:
```
module "couchbase" {

  source = "git::github_url_of_this_repo"

  machine_type = var.machine_type
  name_prefix  = var.name_prefix
  bucket_name  = "${var.name_prefix}_backup"
  project_id   = var.cb_project_id
  image        = var.couchbase_image
  network      = google_compute_network.dev_vpc.name
  subnet       = var.subnet

  // stg cluster sa needs to be passed in
  cb_stg_sa = "fill_me_in"

  // total data nodes count, including init node
  // there's 1 index replica so at least 2 index nodes needed here
  data_node_count  = var.data_node_count
  index_node_count = var.index_node_count

}
```

## Tagging
Tags are manually pushed to repo, and releases are then created.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.82.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.82.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.82.0 |
| <a name="provider_template"></a> [template](#provider\_template) | ~> 2.2.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.data_node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.index_node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.init_node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_service_account.couchbase_vm_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.cb_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.prd_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.staging_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/0.7.2/docs/resources/sleep) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [template_file.add_data_nodes](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.add_index_nodes](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | name of the bucket to upload buckets to without actual data | `string` | n/a | yes |
| <a name="input_cb_stg_sa"></a> [cb\_stg\_sa](#input\_cb\_stg\_sa) | project for couchbase vm creation | `string` | n/a | yes |
| <a name="input_data_node_count"></a> [data\_node\_count](#input\_data\_node\_count) | number of data nodes to spin up | `number` | n/a | yes |
| <a name="input_del_protect"></a> [del\_protect](#input\_del\_protect) | vm instance deletion protection | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | boot disk size | `number` | `120` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | boot disk type | `string` | `"pd-ssd"` | no |
| <a name="input_image"></a> [image](#input\_image) | couchbase image for the vm | `string` | n/a | yes |
| <a name="input_index_node_count"></a> [index\_node\_count](#input\_index\_node\_count) | number of data nodes to spin up | `number` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | machine type of the instance template | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | name prefix to avoid conflict when deleting old and creating new templates, as it's immutable | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | network the vm resides in | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project for couchbase vm creation | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | subnet the vm resides in | `string` | `"region_name"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boot_disk"></a> [boot\_disk](#output\_boot\_disk) | couchbase image for the vm |
| <a name="output_data_node_count"></a> [data\_node\_count](#output\_data\_node\_count) | number of data nodes to spin up |
| <a name="output_index_node_count"></a> [index\_node\_count](#output\_index\_node\_count) | number of data nodes to spin up |
| <a name="output_network"></a> [network](#output\_network) | network the vm resides in |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | project for couchbase vm creation |
<!-- END_TF_DOCS -->
