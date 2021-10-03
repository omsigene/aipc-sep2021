variable DO_token {
    type = string
    sensitive = true
}
variable DO_image {
    type = string
    default = "ubuntu-20-04-x64"
}
variable DO_region {
    type = string
    default = "sgp1"
}
variable DO_size {
    type = string
    default = "s-1vcpu-1gb"
}

data digitalocean_ssh_key aipc {
    name = "aipc-sept27"
}

resource "digitalocean_droplet" "my-droplet" {
    name = "my-droplet"
    region = var.DO_region
    size = var.DO_size
    image = var.DO_image
    ssh_keys = [ data.digitalocean_ssh_key.aipc.id ]

    // setup a connection object
    connection {
        type = "ssh"
        user = "root"
        host = self.ipv4_address
        private_key = file("../keys/aipc")
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt update", // update the repo
            "sudo apt install -y nginx mysql", // install nginx
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx",
        ]
    }
}

resource "local_file" "root_at_ip" {
    content = "The private ipv4 is ${digitalocean_droplet.my-droplet.ipv4_address_private}"
    filename = "root@${digitalocean_droplet.my-droplet.ipv4_address}"
    file_permission = "0444"
}

output droplet_ipv4 {
    value = digitalocean_droplet.my-droplet.ipv4_address
}
output droplet_private_ipv4 {
    value = digitalocean_droplet.my-droplet.ipv4_address_private
}
