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
$ curl http://simplehttpserver.service.consul:8000/
$ curl http://nginx.service.consul/
$ curl http://nginx.service.consul/nginx/
$ curl http://traefik.service.consul:8080/
$ curl http://traefik.service.consul:8080/traefik/
```

Also you can check the nomad and consul status on the web browser. Please access here.

- Nomad UI http://localhost:4646/
- Consul UI http://localhost:8500/

### Stopping a job

```console
$ vagrant ssh -c "sudo nomad stop traefik-example"

$ vagrant destroy
```
