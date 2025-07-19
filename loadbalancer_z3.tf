resource "yandex_alb_http_router" "ssa-alb-router" {
  name   = "ssa-alb-router"
}

resource "yandex_alb_backend_group" "ssa-alb-backend-group" {
  name = "ssa-alb-backend-group"
  http_backend {
    name             = "ssa-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.ssa-alb-target-group.id}"]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout  = "3s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_target_group" "ssa-alb-target-group" {
  name        = "ssa-alb-target-group"
  folder_id = var.folder_id
  dynamic "target" {
    for_each = [for s in yandex_compute_instance_group.ssa-instancegroup.instances : {
      address = s.network_interface.0.ip_address
    }]
    content {
      subnet_id = yandex_vpc_subnet.ssa_network.id
      ip_address   = target.value.address
    }
  }
  depends_on = [
    yandex_compute_instance_group.ssa-instancegroup
  ]
}

resource "yandex_alb_virtual_host" "ssa-alb-host" {
  name           = "ssa-alb-host"
  http_router_id = yandex_alb_http_router.ssa-alb-router.id
  route {
    name = "ssa-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.ssa-alb-backend-group.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "ssa-alb" {
  name               = "ssa-alb"
  network_id         = yandex_vpc_network.ssa_network.id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.ssa_network.id
    }
  }
  listener {
    name = "ssa-alb-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.ssa-address.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.ssa-alb-router.id
      }
    }
  }
  depends_on = [
    yandex_alb_backend_group.ssa-alb-backend-group,
    yandex_alb_target_group.ssa-alb-target-group
  ]
}