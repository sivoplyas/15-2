resource "yandex_iam_service_account" "sa-bucket" {
  name      = "sa-bucket"
}

resource "yandex_resourcemanager_folder_iam_member" "resourcemanager-sa-bucket" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-bucket-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
}

resource "yandex_storage_bucket" "ssa-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-bucket-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-static-key.secret_key
  bucket    = var.bucket_name
  folder_id = var.folder_id
  acl        = "public-read"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
  website {
    index_document = "picture.jpg"
  }
  https {
    certificate_id = data.yandex_cm_certificate.ssa-cm-certificate.id
  }
}

resource "yandex_storage_object" "object" {
  access_key = yandex_iam_service_account_static_access_key.sa-bucket-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-static-key.secret_key
  bucket     = yandex_storage_bucket.ssa-bucket.id
  key        = "picture.jpg"
  source     = "./picture/picture.jpg"
}

resource "yandex_dns_zone" "ssa-zone" {
  name        = "ssa-zone"
  zone        = "${var.domain_name}."
  public      = true
}

resource "yandex_dns_recordset" "ssa-recordset" {
  zone_id = yandex_dns_zone.ssa-zone.id
  name    = "${var.domain_name}."
  type    = "ANAME"
  ttl     = 600
  data    = ["${var.domain_name}.website.yandexcloud.net"]
}

resource "yandex_cm_certificate" "ssa-letsencrypt-certificate" {
  name    = "letsencrypt-certificate"
  domains = ["${var.domain_name}"]

  managed {
  challenge_type = "DNS_CNAME"
  }
}

resource "yandex_dns_recordset" "ssa-validation-record" {
  zone_id = yandex_dns_zone.ssa-zone.id
  name    = yandex_cm_certificate.ssa-letsencrypt-certificate.challenges[0].dns_name
  type    = yandex_cm_certificate.ssa-letsencrypt-certificate.challenges[0].dns_type
  data    = [yandex_cm_certificate.ssa-letsencrypt-certificate.challenges[0].dns_value]
  ttl     = 600
}

data "yandex_cm_certificate" "ssa-cm-certificate" {
  depends_on      = [yandex_dns_recordset.ssa-validation-record]
  certificate_id  = yandex_cm_certificate.ssa-letsencrypt-certificate.id
  #wait_validation = true
}
