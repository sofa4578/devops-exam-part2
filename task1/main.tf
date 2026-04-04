# 1. Віртуальна приватна хмара (VPC)
resource "digitalocean_vpc" "vpc" {
  name     = "levko-vpc"
  region   = "fra1" # Франкфурт - найближче до України
  ip_range = "10.10.10.0/24"
}

# 2. Сховище для обʼєктів (Бакет)
resource "digitalocean_spaces_bucket" "bucket" {
  name   = "levko-bucket-${random_id.bucket_suffix.hex}" # Додаємо суфікс, бо імена бакетів мають бути унікальними в усьому світі
  region = "fra1"
}

# Генерація випадкового суфікса для унікальності бакета
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 3. Віртуальна машина (Droplet)
resource "digitalocean_droplet" "node" {
  name     = "levko-node"
  region   = "fra1"
  size     = "s-2vcpu-4gb" # Вимоги Minikube (мінімум 2 CPU, 2+ GB RAM)
  image    = "ubuntu-24-04-x64" # Образ ОС Ubuntu 24
  vpc_uuid = digitalocean_vpc.vpc.id
}

# 4. Налаштування фаєрволу
resource "digitalocean_firewall" "firewall" {
  name = "levko-firewall"

  # Прив'язуємо фаєрвол до нашої ВМ
  droplet_ids =[digitalocean_droplet.node.id]

  # Вхідні підключення
  dynamic "inbound_rule" {
    for_each =["22", "80", "443", "8000", "8001", "8002", "8003"]
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  # Вихідні підключення (1-65535) - дозволяємо TCP та UDP
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses =["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses =["0.0.0.0/0", "::/0"]
  }
}