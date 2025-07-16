terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.141.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
required_version = "~>1.9"

# Подключение бакета s3 для удаленного хранения 
# backend "s3" {
#   endpoints = {
#       s3 = "https://storage.yandexcloud.net"
#     }
#     bucket = "tfstate-final-tr"
#     region = "ru-central1"
#     key    = "terraform.tfstate"

#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
#     skip_s3_checksum            = true # Необходимая опция при описании backend для Terraform версии 1.6.3 и старше.

#     dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gv70mvh8quh0edjcqr/etn1d8ghjlnibrt1q69n"
#     dynamodb_table = "tfstate-lock"
#   }
}

# Подключение модуля создания сети; подсетей
module "vpc_dev" {
  source    = "./vpc_dev"
  env_name  = var.vpc_name
  folder_id = var.folder_id
  subnets   = [
    { zone = var.zone, cidr = "10.0.10.0/24" }
  ]
}

# Подключение модуля создания container registry в YC
# module "container_registry" {
#   source = "./container_registry"

#   folder_id = var.folder_id
#   cloud_id = var.cloud_id
#   zone = var.zone
# }

# Подключение модуля создания s3bucket в YC для remote state
# module "s3bucket" {
#   source = "./s3bucket"

#   folder_id = var.folder_id
#   cloud_id = var.cloud_id
#   zone = var.zone
#   source_file = var.source_file
# }

# # Подключение модуля создания YDB для state-locking
# module "ydb_dev" {
#   source = "./ydb_dev"

#   folder_id = var.folder_id
#   cloud_id = var.cloud_id
#   zone = var.zone
#   file = var.source_file
# }

# Подключение модуля создания VM в любом указаном количестве (instance_count)
module "vm_create" {
  source         = "./vm_create"
  env_name       = var.vpc_name
  network_id     = module.vpc_dev.net_id
  subnet_zones   = values(module.vpc_dev.zone)
  subnet_ids     = values(module.vpc_dev.subnet_id)
  instance_name  = var.vms_resources.instance_name
  instance_count = var.vms_resources.instance_count
  image_family   = var.vms_resources.image_family
  public_ip      = var.vms_resources.public_ip
  
  yandex_vpc_network_petapp_id = module.vpc_dev.net_id
  
  folder_id = var.folder_id
  cloud_id = var.cloud_id
  zone = var.zone
  ssh_public_key = var.metadata_base.ssh_public_key

  labels = { 
    owner   = "n.leonov",
    project = "petapp_infr"
     }

  metadata = {
    ssh-keys           = "${var.metadata_base.ssh_name}:${var.metadata_base.ssh_public_key}"
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = var.metadata_base.serial-port-enable
  }
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_name       = var.metadata_base.ssh_name
    ssh_public_key = var.metadata_base.ssh_public_key
  }
}