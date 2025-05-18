Vagrant.configure("2") do |config|
  # Base box (OS image)
  config.vm.box = "bento/ubuntu-24.04"

  # Mount shared folder into all VMs at /mnt/shared
  config.vm.synced_folder "./shared", "/mnt/shared", create: true

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

  # GENERAL (all hosts)
  config.vm.provision "ansible_general", type: "ansible" do |ansible|
    ansible.playbook       = "playbooks/general.yml"
    ansible.inventory_path = "inventory.cfg"
    ansible.extra_vars     = {
      num_workers: NUM_WORKERS
    }
  end

  # CTRL (control-plane only)
  config.vm.provision "ansible_ctrl", type: "ansible" do |ansible|
    ansible.playbook       = "playbooks/ctrl.yml"
    ansible.inventory_path = "inventory.cfg"
    ansible.extra_vars     = {
      ingress_loadbalancer_ip: "192.168.56.95"
    }
  end

  # NODES (worker nodes only)
  config.vm.provision "ansible_nodes", type: "ansible" do |ansible|
    ansible.playbook       = "playbooks/node.yml"
    ansible.inventory_path = "inventory.cfg"
  end

  # FINALIZE (MetalLB, Ingress, Dashboard)
  config.vm.provision "ansible_finalize", type: "ansible" do |ansible|
    ansible.playbook       = "playbooks/finalization.yml"
    ansible.inventory_path = "inventory.cfg"
    ansible.extra_vars     = {
      ingress_loadbalancer_ip: "192.168.56.95"
    }
  end
end
