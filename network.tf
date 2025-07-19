resource "yandex_vpc_network" "ssa_network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "ssa_network" {
  name           = var.vpc_name
  zone           = var.zone
  network_id     = yandex_vpc_network.ssa_network.id
  v4_cidr_blocks = var.cidr
}

resource "yandex_vpc_address" "ssa-address" {
  name = "ssa-address"
  external_ipv4_address {
    zone_id                  = var.zone
    ddos_protection_provider = "qrator"
  }
}

