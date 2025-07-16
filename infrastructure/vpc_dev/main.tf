terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.141.0"
    }
  }
  required_version = "~>1.9"
}

resource "yandex_vpc_network" "petnet" {
  name = var.env_name
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "sub_petnet" {
  for_each = { for i, s in var.subnets: i => s }
  name = "${var.env_name}-${each.value.zone}"
  zone = each.value.zone
  folder_id = var.folder_id
  v4_cidr_blocks = [each.value.cidr]
  network_id     = yandex_vpc_network.petnet.id
}