variable "token" {
  type        = string
  default     = ""
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "network_name" {
  type        = string
  default     = ""
  description = "VPC network name"
}

variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "bucket_name" {
  type        = string
  default     = "ssa-bucket"
  description = "Bucket name"
}

variable "domain_name" {
  type        = string
  default     = "ssa-bucket.ru"
  description = "Bucket name"
}

variable "ssa_vm" {
  type        = string
  default     = "ssa-vm"
  description = "Virtual machine instance group name"
}

variable "ssa_protection" {
  type        = bool
  default     = false
  description = "Use instance group delete protection"
}

variable "ssa_platform_id_vm" {
  type        = string
  default     = "standard-v1"
  description = "Yandex platform ID for this virtual machine"
}

variable "ram" {
  type        = number
  default     = 2
  description = "RAM capacity for this virtual machine"
}

variable "cpu" {
  type        = number
  default     = 2
  description = "Number of CPU cores for this virtual machine"
}

variable "core" {
  type        = number
  default     = 5
  description = "CPU core fraction in percents for this virtual machine"
}

variable "image_id" {
  type        = string
  default     = "fd827b91d99psvq5fjit"
  description = "OS image for this virtual machine"
}

variable "disk_type" {
  type        = string
  default     = "network-hdd"
  description = "Disk type for this virtusl machine"
}

variable "disk_size" {
  type        = number
  default     = 10
  description = "Disk size in Gb"
}

variable "nat" {
  type        = bool
  default     = true
  description = "This virtual machine use nat"
}

variable "vm_preemptible" {
  type        = bool
  default     = true
  description = "This virtual machine is preemptible"
}

variable "serial_port" {
  type        = number
  default     = 0
  description = "This virtual machine serial port is enable (1-yes,0-no)?"
}

variable "default_user" {
  type        = string
  default     = "ubuntu"
  description = "Default user via ssh"
}

variable "scale_policy" {
  type        = number
  default     = 3
  description = "Fixed scale for instance group scale policy"
}

variable "max_unavailable" {
  type        = number
  default     = 1
  description = "Max unavailable instance for instance group deploy polycy"
}

variable "max_expansion" {
  type        = number
  default     = 0
  description = "Max expansion instance for instance group deploy polycy"
}

variable "healthcheck_interval" {
  type        = number
  default     = 10
  description = "Health check test interval in sec"
}

variable "healthcheck_timeout" {
  type        = number
  default     = 2
  description = "Health check test timeout in sec"
}

variable "healthcheck_port" {
  type        = number
  default     = 80
  description = "Health check TCP port"
}

variable "vpc_name" {
  type        = string
  default     = "ssa_network"
  description = "VPC network&subnet name"
}

variable "cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}