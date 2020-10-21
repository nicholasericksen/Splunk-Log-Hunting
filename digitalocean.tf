variable "DO" {}
variable "PRIVATE" {}
variable "PUBLIC" {}

provider "digitalocean" {
  token = var.DO
}

resource "digitalocean_ssh_key" "terraform-new" {
  name       = "DO Terraform New"
  public_key = file(var.PUBLIC)
}

resource "digitalocean_droplet" "attacker" {
  image              = "centos-7-x64"
  name               = "splunk-kali-linux"
  region             = "nyc1"
  size               = "s-1vcpu-2gb"
  monitoring         = false
  ipv6               = false
  private_networking = true
  ssh_keys           = [digitalocean_ssh_key.terraform-new.fingerprint]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.PRIVATE)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    scripts = [
      "bin/base-install.sh",
      "bin/kali-install.sh",
      "bin/splunk-install.sh"
    ]
  }
}
resource "digitalocean_droplet" "victim" {
  image              = "centos-7-x64"
  name               = "vulnerable-host"
  region             = "sgp1"
  size               = "s-1vcpu-2gb"
  monitoring         = false
  ipv6               = false
  private_networking = true
  ssh_keys           = [digitalocean_ssh_key.terraform-new.fingerprint]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.PRIVATE)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${digitalocean_droplet.attacker.ipv4_address} splunkhost' | sudo tee -a /etc/hosts > /dev/null"
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "bin/base-install.sh",
      "bin/splunk-logging-configure.sh",
      "bin/vulnhub-install.sh"
    ]
  }

}

resource "digitalocean_firewall" "splunk" {
  name = "fw-splunk-kali"

  droplet_ids = [digitalocean_droplet.attacker.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["47.17.123.145"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["47.17.123.145"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["47.17.123.145"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8088-8089"
    source_addresses = ["47.17.123.145", digitalocean_droplet.victim.ipv4_address]

  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["47.17.123.145"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "victim" {
  name = "fw-vulnhub"

  droplet_ids = [digitalocean_droplet.victim.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["47.17.123.145"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["47.17.123.145"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7000-9000"
    source_addresses = ["0.0.0.0/0"]

  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["47.17.123.145"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

