resource "yandex_iam_service_account" "sa-instancegroup" {
  name               = "sa-instancegroup"
}

resource "yandex_resourcemanager_folder_iam_member" "resourcemanagersa-sa-instancegroup" {
  folder_id = var.folder_id
  role               = "editor"
  member             = "serviceAccount:${yandex_iam_service_account.sa-instancegroup.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-instancegroup-static-key" {
  service_account_id = yandex_iam_service_account.sa-instancegroup.id
}

resource "yandex_compute_instance_group" "ssa-instancegroup" {
  name               = var.ssa_vm
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.sa-instancegroup.id
  deletion_protection = var.ssa_protection
  instance_template {
    platform_id      = var.ssa_platform_id_vm
    resources {
      memory         = var.ram
      cores          = var.cpu
      core_fraction  = var.core
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id     = var.image_id
        type         = var.disk_type
        size         = var.disk_size
      }
    }
    network_interface {
      network_id     = yandex_vpc_network.ssa_network.id
      subnet_ids     = [yandex_vpc_subnet.ssa_network.id]
      nat            = var.nat
    }
    scheduling_policy {
      preemptible    = var.vm_preemptible
    }
    metadata         = {
      serial-port-enable      = var.serial_port
      ssh-keys                = "${var.default_user}:${local.public_ssh_key_pub}"
      user-data               = <<-EOF
        #cloud-config
        runcmd:
          - echo '<!doctype html><html><head><title>https://ssa-bucket.website.yandexcloud.net</title></head><body><img src="https://ssa-bucket.website.yandexcloud.net" /></body></html>' | sudo tee /var/www/html/index.html
          - sudo systemctl restart apache2
      EOF
    }
  }
  scale_policy {
    fixed_scale {
      size           = var.scale_policy
    }
  }
  allocation_policy {
    zones            = ["${var.zone}"]
  }
  deploy_policy {
    max_unavailable  = var.max_unavailable
    max_expansion    = var.max_expansion
  }
  health_check {
    interval = var.healthcheck_interval
    timeout  = var.healthcheck_timeout
    tcp_options {
      port = var.healthcheck_port
    }
  }
  load_balancer {
    target_group_name        = "ssa-loadbalancer-target-group"
  }
  depends_on = [yandex_resourcemanager_folder_iam_member.resourcemanagersa-sa-instancegroup]
}

