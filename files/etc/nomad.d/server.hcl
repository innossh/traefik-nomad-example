bind_addr = "0.0.0.0"
datacenter = "dc1"
name = "nomad"
data_dir  = "/var/lib/nomad"

advertise {
  http = "10.0.2.15"
  rpc  = "10.0.2.15"
  serf = "10.0.2.15"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled       = true
  network_interface = "eth0"
}

consul {
  address = "127.0.0.1:8500"
}
