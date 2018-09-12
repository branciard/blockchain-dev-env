Vagrant.configure("2") do |config|
  config.vm.define "dapps" do |dapps|
    dapps.vm.box = "bento/ubuntu-18.04"
    # Change from "~/dapps" to an existing, and non-encrypted, folder on your host if the mount fails
    dapps.vm.synced_folder "~/dapps", "/home/vagrant/dapps", nfs: true, nfs_udp: false, create: true
    dapps.vm.network "private_network", type: "dhcp"
    dapps.vm.network :forwarded_port, guest: 8545, host: 8545
    dapps.vm.network :forwarded_port, guest: 8546, host: 8546
    dapps.vm.network :forwarded_port, guest: 8080, host: 8080
    dapps.vm.network :forwarded_port, guest: 8180, host: 8180
    dapps.vm.network :forwarded_port, guest: 30303, host: 30303
    dapps.vm.network :forwarded_port, guest: 3001, host: 3001
    dapps.vm.network :forwarded_port, guest: 3000, host: 3000


    # IPFS
    dapps.vm.network :forwarded_port, guest: 4001, host: 4001
    dapps.vm.network :forwarded_port, guest: 5001, host: 5001
    dapps.vm.network :forwarded_port, guest: 8080, host: 8080

    dapps.vm.provider "virtualbox" do |v|
      host = RbConfig::CONFIG['host_os']
       v.memory = 10000
       v.cpus = 2
    end

    dapps.vm.provision "file", source: "dotscreenrc", destination: "~/.screenrc"

    dapps.vm.provision :shell, path: "bootstrap-ubuntu-vagrant.sh"
  end
end
