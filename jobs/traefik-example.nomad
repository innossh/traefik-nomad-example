job "traefik-example" {
  region = "global"
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1    
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }

  group "proxy" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:1.12.2-alpine"
        port_map {
          http = 80
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/vagrant/files/etc/nginx/conf.d:/etc/nginx/conf.d"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          mbits = 10
          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "nginx"
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v1.5.4-alpine"
        port_map {
          http = 8080
          api = 8081
        }
        dns_servers = [
          "172.17.0.1"
        ]
        volumes = [
          "/vagrant/files/etc/traefik:/etc/traefik"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
          port "api" {
            static = 8081
          }
        }
      }

      service {
        name = "traefik"
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

  }

  group "web" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 300
    }

    task "httpserver0" {
      driver = "docker"

      config {
        image = "python:3.6.4-alpine3.7"
        command = "python3"
        args = [
          "-m",
          "http.server",
          "8000"
        ]
        port_map {
          http = 8000
        }
        dns_servers = [
          "172.17.0.1"
        ]
        work_dir = "/var/www/html/0"
        volumes = [
          "/vagrant/files/var/www/html:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          mbits = 5
          port "http" {
            static = 8000
          }
        }
      }

      service {
        name = "httpserver0"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/0/",
        ]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "httpserver1" {
      driver = "docker"

      config {
        image = "python:3.6.4-alpine3.7"
        command = "python3"
        args = [
          "-m",
          "http.server",
          "8001"
        ]
        port_map {
          http = 8001
        }
        dns_servers = [
          "172.17.0.1"
        ]
        work_dir = "/var/www/html/1"
        volumes = [
          "/vagrant/files/var/www/html:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 64
        network {
          mbits = 5
          port "http" {
            static = 8001
          }
        }
      }

      service {
        name = "httpserver1"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/1/",
        ]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

}