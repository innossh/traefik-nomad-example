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
        volumes = [
          "/vagrant/files/etc/nginx/conf.d:/etc/nginx/conf.d"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
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
        volumes = [
          "/vagrant/files/etc/traefik:/etc/traefik"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
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

    task "simplehttpserver" {
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
        work_dir = "/var/www/html"
        volumes = [
          "/vagrant/files/var/www/html:/var/www/html"
        ]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          mbits = 10
          port "http" {
            static = 8000
          }
        }
      }

      service {
        name = "simplehttpserver"
        tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefix:/traefik",
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