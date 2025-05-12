Vagrant.configure("2") do |config|
  # Base box (OS image)
  config.vm.box = "bento/ubuntu-24.04"

  # Variables to control the cluster
  NUM_WORKERS = 2
  CTRL_IP = "192.168.56.100"
  WORKER_BASE_IP = 101
  SUBNET_PREFIX = "192.168.56."

  # Define the control node
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: CTRL_IP
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 2
    end
  end

  # Define the worker nodes using a loop
  (1..NUM_WORKERS).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "#{SUBNET_PREFIX}#{WORKER_BASE_IP + i - 1}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 6144
        vb.cpus = 2
      end
    end
  end

  # Shared Ansible provisioner for all machines
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbooks/general.yml"
    ansible.inventory_path = "inventory.cfg"
    ansible.extra_vars = {
      num_workers: NUM_WORKERS
    }
  end



  
end
