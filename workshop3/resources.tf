variable DO_token {
    type = string
    sensitive = true
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
    name = "aipc-sep27"
}

data digitalocean_image mysql8 {
    name = "mysql8"
}

resource digitalocean_droplet mysql8-sgp1 {
    name = "mysql8-sgp1"
    image = data.digitalocean_image.mysql8.id
    region = var.DO_region
    size = var.DO_size
    ssh_keys = [ data.digitalocean_ssh_key.aipc.id ]
}

resource local_file root_at_ip {
    filename = "root@${digitalocean_droplet.mysql8-sgp1.ipv4_address}"
    file_permission = "0444"
}

output mysql8_enpoint {
    value = "${digitalocean_droplet.mysql8-sgp1.ipv4_address}:3306"    
}