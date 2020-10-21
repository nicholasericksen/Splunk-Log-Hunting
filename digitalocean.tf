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
  name               = "kali-linux"
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

