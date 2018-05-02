# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copied from https://github.com/hashicorp/nomad/blob/v0.8.3/demo/vagrant

$script = <<SCRIPT
# Update apt and get dependencies
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl vim \
    apt-transport-https \
    ca-certificates \
    software-properties-common

# Download Nomad
NOMAD_VERSION=0.8.3

echo "Fetching Nomad..."
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip

echo "Fetching Consul..."
CONSUL_VERSION=1.0.7
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip

echo "Fetching Prometheus..."
PROMETHEUS_VERSION=2.2.1
curl -sSL https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz > prometheus.tar.gz

echo "Fetching Grafana..."
GRAFANA_VERSION=5.1.0
curl -sSL https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb > grafana.deb

echo "Installing Nomad..."
unzip nomad.zip
sudo install nomad /usr/bin/nomad

sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
sudo mkdir -p /var/lib/nomad
sudo chmod a+w /var/lib/nomad

# Set hostname's IP to made advertisement Just Work
#sudo sed -i -e "s/.*nomad.*/192.168.1.21 nomad/" /etc/hosts

echo "Installing Docker..."
if [[ -f /etc/apt/sources.list.d/docker.list ]]; then
    echo "Docker repository already installed; Skipping"
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
fi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce

# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart

# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant

echo "Installing Consul..."
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
sudo mkdir -p /var/lib/consul
sudo chmod a+w /var/lib/consul
(
cat <<-EOF
	[Unit]
	Description=consul agent
	Requires=network-online.target
	After=network-online.target
	
	[Service]
	Restart=on-failure
	ExecStart=/usr/bin/consul agent -config-dir=/vagrant/files/etc/consul.d
	ExecReload=/bin/kill -HUP $MAINPID
	
	[Install]
	WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service
sudo systemctl enable consul.service
sudo systemctl start consul

for bin in cfssl cfssl-certinfo cfssljson
do
	echo "Installing $bin..."
	curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
	sudo install /tmp/${bin} /usr/local/bin/${bin}
done

echo "Installing autocomplete..."
nomad -autocomplete-install

echo "Installing dnsmasq..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dnsmasq
echo "server=/consul/127.0.0.1#8600" | sudo tee /etc/dnsmasq.conf
sudo systemctl enable dnsmasq.service
sudo systemctl restart dnsmasq

echo "Starting nomad..."
(
cat <<-EOF
	[Unit]
	Description=nomad agent
	Requires=network-online.target
	After=network-online.target
	
	[Service]
	Restart=on-failure
	ExecStart=/usr/bin/nomad agent -config=/vagrant/files/etc/nomad.d
	ExecReload=/bin/kill -HUP $MAINPID
	
	[Install]
	WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service
sudo systemctl enable nomad.service
sudo systemctl start nomad

echo "Installing Prometheus..."
tar xfz /tmp/prometheus.tar.gz
sudo install prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/prometheus
sudo install prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/promtool
sudo mkdir -p /var/lib/prometheus
sudo chmod a+w /var/lib/prometheus
(
cat <<-EOF
	[Unit]
	Description=prometheus
	Requires=network-online.target
	After=network-online.target
	
	[Service]
	Restart=always
	ExecStart=/usr/local/bin/prometheus --config.file=/vagrant/files/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data
	ExecReload=/bin/kill -HUP $MAINPID
	
	[Install]
	WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/prometheus.service
sudo systemctl enable prometheus.service
sudo systemctl start prometheus

echo "Installing Grafana..."
sudo apt-get install -y adduser libfontconfig
sudo dpkg -i /tmp/grafana.deb
sudo systemctl start grafana-server
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
  config.vm.box_version = "201802.02.0"
  config.vm.hostname = "nomad"
  config.vm.provision "shell", inline: $script, privileged: false
  config.vm.provision "docker" # Just install it
  
  # Expose the nomad api and ui to the host
  config.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true

  # Expose the consul api and ui to the host
  config.vm.network "forwarded_port", guest: 8500, host: 8500

  # Expose the prometheus server to the host
  config.vm.network "forwarded_port", guest: 9090, host: 9090

  # Expose the grafana ui to the host
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # Increase memory for Parallels Desktop
  config.vm.provider "parallels" do |p, o|
    p.memory = "1024"
  end

  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
  end

  # Increase memory for VMware
  ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = "1024"
    end
  end
end
