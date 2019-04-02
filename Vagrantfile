Vagrant.configure("2") do |config|
  config.vm.define "dapps" do |dapps|
    dapps.vm.box = "ubuntu/xenial64"
    # Change from "~/dapps" to an existing, and non-encrypted, folder on your host if the mount fails
    #dapps.vm.synced_folder "~/vagrant", "/home/vagrant/dapps", nfs: true, nfs_udp: false, create: true
    dapps.vm.network "private_network", ip: "192.168.50.4"
    #dapps.vm.network "private_network", type: "dhcp"
    dapps.vm.network :forwarded_port, guest: 8545, host: 8545
    dapps.vm.network :forwarded_port, guest: 9545, host: 9545
    


    dapps.vm.provider "virtualbox" do |v|
      host = RbConfig::CONFIG['host_os']

      # Setup hardware config, host-os specific. Your host should have at least 6GB memory
      if host =~ /darwin/
        # mac
        cpus = `sysctl -n hw.ncpu`.to_i
        # sysctl returns Bytes and we need to convert to MB
        # mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
        mem = 3572
      elsif host =~ /linux/
        # linux
        cpus = `nproc`.to_i
        # meminfo shows KB and we need to convert to MB
        # mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
        mem = 3572
      else
        # windows
        cpus = 2
        mem = 3572
      end

      v.customize ["modifyvm", :id, "--memory", mem]
      v.customize ["modifyvm", :id, "--cpus", cpus]
      #v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]

    end

    dapps.vm.provision "file", source: "dotscreenrc", destination: "~/.screenrc"

    dapps.vm.provision :shell, path: "bootstrap-ubuntu-bridge-demo.sh"
  end
end
