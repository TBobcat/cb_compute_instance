// required variables don't have default value, and needs to be passed down from 
// root module. variagles.tf needs to have all required variables from resources
// created within.


variable "machine_type" {
  description = "machine type of the instance template"
  type        = string
}

variable "name_prefix" {
  description = "name prefix to avoid conflict when deleting old and creating new templates, as it's immutable"
  type        = string
}

# variable "network_interface" {
#   description = "network interface for the instances defined in this template"
#   type        = map(any)
# }

variable "data_node_count" {
  description = "number of data nodes to spin up"
  type        = number
}

variable "index_node_count" {
  description = "number of data nodes to spin up"
  type        = number
}


variable "project_id" {
  description = "project for couchbase vm creation"
  type        = string
}

// packer couchbase image to be put in
variable "image" {
  description = "couchbase image for the vm"
  type        = string
}


## optional variables that have default value specified
#################################################################################

variable "del_protect" {
  description = "vm instance deletion protection"
  type        = bool
  default     = true
}

variable "disk_type" {
  description = "boot disk type"
  type        = string
  default     = "pd-ssd"
}

variable "disk_size" {
  description = "boot disk size"
  type        = number
  default     = 120
}

variable "network" {
  description = "network the vm resides in"
  type        = string
}


variable "subnet" {
  description = "subnet the vm resides in"
  type        = string
  default     = "region_name"
}


variable "bucket_name" {
  description = "name of the bucket to upload buckets to without actual data"
  type        = string
}

variable "cb_stg_sa" {
  description = "service account of the skeleton source cluster"
  type        = string
}

