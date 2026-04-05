# 1. Віртуальна приватна хмара (VPC)
resource "digitalocean_vpc" "vpc" {
  name     = "levko-vpc"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

# 2. Сховище для обʼєктів (Бакет)
resource "digitalocean_spaces_bucket" "bucket" {
  name   = "levko-bucket-${random_id.bucket_suffix.hex}"
  region = "fra1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 3. Віртуальна машина (Droplet) з ключем Ansible
resource "digitalocean_droplet" "node" {
  name     = "levko-node"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.vpc.id
  ssh_keys =[digitalocean_ssh_key.ansible_key.id]
}

# 4. Налаштування фаєрволу
resource "digitalocean_firewall" "firewall" {
  name = "levko-firewall"
  droplet_ids = [digitalocean_droplet.node.id]

  dynamic "inbound_rule" {
    for_each =["22", "80", "443", "8000", "8001", "8002", "8003"]
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses =["0.0.0.0/0", "::/0"]
    }
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses =["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# 5. SSH ключ для доступу Ansible
resource "digitalocean_ssh_key" "ansible_key" {
  name       = "levko-ansible-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhRRWa8o+cxCSy/4OFb0A521kZiE9/h7T+2m5QzeFSM admin@Sofa"
}