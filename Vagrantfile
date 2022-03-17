# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "default",primary: true do |master|
    config.vm.network "private_network", ip: "192.168.21.100"
    config.vm.network "forwarded_port", id: "ssh", host: 2222, guest: 22
    config.vm.network "forwarded_port", id: "httpd", host: 8080, guest: 80
  end

  config.vm.provider "docker" do |d, override|
    d.build_dir = "."
    d.remains_running = true
    d.has_ssh = true
  end

  # load external file that holds your github oauth token
  composer_github_oauth = ""
  custom_vagrantfile = 'Vagrantfile.local'
  if File.exist?(custom_vagrantfile)
    external = File.read custom_vagrantfile
    eval external
  end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "vagrant": true,
      "deploy": {
        "webapp": {
          "name": "test",
          "application": "test",
          "application_type": "php",
          "deploy_to": "/vagrant",
          "document_root": "html"
        }
      }
    }

    chef.arguments = '--chef-license accept'
    chef.product = "chef-workstation"
    chef.cookbooks_path = ["./vagrant/cookbooks"]

    chef.add_recipe "before_symlink"
  end
end
