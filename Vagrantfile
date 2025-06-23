# Variables to control the cluster
  NUM_WORKERS = 2
  CTRL_IP = "192.168.56.100"
  WORKER_BASE_IP = 101
  SUBNET_PREFIX = "192.168.56."
  WORKER_CPUS = 2
  WORKER_MEM = 6144
  CTRL_CPUS = 2
  CTRL_MEM = 4096

Vagrant.configure("2") do |config|
  # Base box (OS image)
  config.vm.box = "bento/ubuntu-24.04"

  # Generate inventroy.cfg
  config.trigger.after [:up, :reload] do |trigger|
    trigger.name = "Generate ansible inventory file"
    trigger.ruby do
      require 'fileutils'

      inventory_file = "inventory.cfg"
      controller = "ctrl"
      vagrant_path = ".vagrant/machines"

      File.open(inventory_file, "w") do |f|
        f.puts "[controller]"
        f.puts "#{controller} ansible_host=#{CTRL_IP} ansible_user=vagrant " \
              "ansible_ssh_private_key_file=./#{vagrant_path}/#{controller}/virtualbox/private_key " 
        f.puts ""

        f.puts "[nodes]"
        NUM_WORKERS.times do |i|
          name = "node-#{i + 1}"
          ip = "#{SUBNET_PREFIX}#{WORKER_BASE_IP + i}"
          f.puts "#{name} ansible_host=#{ip} ansible_user=vagrant " \
                "ansible_ssh_private_key_file=./#{vagrant_path}/#{name}/virtualbox/private_key " 
        end

        f.puts "\n[all:children]\ncontroller\nnodes\n"

        f.puts "\n[all:vars]\nansible_user=vagrant\nansible_ssh_common_args='-o IdentitiesOnly=yes -o StrictHostKeyChecking=no'"
      end
    end
  end

  config.trigger.after :up do |trigger|
    trigger.name = "Add dashboard.local app.local model.local grafana.local prometheus.local to /etc/hosts"
    trigger.run = {
      inline: %Q[bash -c 'grep -q "192.168.56.95 dashboard.local app.local model.local grafana.local prometheus.local " /etc/hosts || echo "192.168.56.95 dashboard.local app.local model.local grafana.local prometheus.local" | sudo tee -a /etc/hosts']
    }
  end

  # Define the control node
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: CTRL_IP
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = CTRL_MEM
      vb.cpus = CTRL_CPUS
    end
  end

  # Define the worker nodes using a loop
  (1..NUM_WORKERS).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "#{SUBNET_PREFIX}#{WORKER_BASE_IP + i - 1}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = WORKER_MEM
        vb.cpus = WORKER_CPUS
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

  # # FINALIZE (MetalLB, Ingress, Dashboard)
  # config.vm.provision "ansible_finalize", type: "ansible" do |ansible|
  #   ansible.playbook       = "playbooks/finalization.yml"
  #   ansible.inventory_path = "inventory.cfg"
  #   ansible.extra_vars     = {
  #     ingress_loadbalancer_ip: "192.168.56.95"
  #   }
  # end

  
end