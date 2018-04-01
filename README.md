# traefik-nomad-example

## Getting started

### Starting a job

```console
$ vagrant up

$ vagrant ssh -c "sudo nomad run /vagrant/jobs/traefik-example.nomad"
```

### Confirmation

```console
$ vagrant ssh
$ curl -i http://httpserver0.service.consul:8000/
$ curl -i http://httpserver1.service.consul:8001/
$ curl -i http://nginx.service.consul/0/
$ curl -i http://nginx.service.consul/1/
$ curl -i http://traefik.service.consul:8080/0/
$ curl -i http://traefik.service.consul:8080/1/
```

Also you can check the nomad and consul status on the web browser. Please access here.

- Nomad UI http://localhost:4646/
- Consul UI http://localhost:8500/

### Stopping a job

```console
$ vagrant ssh -c "sudo nomad stop traefik-example"

$ vagrant destroy
```
