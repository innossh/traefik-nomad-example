# traefik-nomad-example

```console
$ vagrant up
$ vagrant ssh -c "sudo nohup nomad agent -bind=0.0.0.0 -dev & sleep 1"
# This is an awful solution, but works https://stackoverflow.com/questions/25331758/vagrant-ssh-c-and-keeping-a-background-process-running-after-connection-closed

$ vagrant ssh -c "sudo nomad run /vagrant/jobs/traefik-example.nomad"
```

```console
$ vagrant ssh -c "sudo nomad stop traefik-example"
```
