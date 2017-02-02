# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 60
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    vb.cpus = 1
    vb.gui = false
  end

  config.vm.define "server" do |server|
    server.vm.host_name = "server"
    server.vm.box = "centos/7"
    # server.vm.network "private_network", ip: "172.28.128.10"
    server.vm.network "private_network", type: "dhcp"
    # server.vm.network "forwarded_port", guest: 1194, host: 1194, auto_correct: true
  end

  config.vm.define "client" do |client|
    client.vm.host_name = "client"
    client.vm.box = "centos/7"
    # client.vm.network "private_network", ip: "172.28.128.11"
    client.vm.network "private_network", type: "dhcp"
  end
end
