# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify Vagrant version and Vagrant API version
Vagrant.require_version '>= 1.8.0'
VAGRANTFILE_API_VERSION = '2'

#  if not Vagrant.has_plugin?(plugin[:name], plugin[:version])
#    raise "#{plugin[:name]} #{plugin[:version]} is required. Please run `vagrant plugin install #{plugin[:name]}`"
#  end

# install required plugins if necessary
if ARGV[0] == 'up'
    # add required plugins here
    required_plugins = %w( vagrant-vbguest )
    missing_plugins = []
    required_plugins.each do |plugin|
        missing_plugins.push(plugin) unless Vagrant.has_plugin? plugin
    end

    if ! missing_plugins.empty?
        install_these = missing_plugins.join(' ')
        puts "Found missing plugins: #{install_these}."
        exec "vagrant plugin install #{install_these}; vagrant up"
    end
end

# Require 'yaml' module
require 'yaml'

# Read YAML file with VM details (box, CPU, and RAM)
machines = YAML.load_file(File.join(File.dirname(__FILE__), 'machines.yml'))

# Create and configure the VMs
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
	# More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
	config.cache.scope = :box
  end

  # Always use Vagrant's default insecure key
  config.ssh.insert_key = true

  # Iterate through entries in YAML file to create VMs
  machines.each do |machine|
  
      config.vm.define machine['name'] do |srv|
      # Don't check for box updates
      srv.vm.box_check_update = false
      srv.vm.hostname = machine['name']

      # Set box to VMware Fusion box by default
      srv.vm.box = machine['vmw_box']

      # Use machine specified install script
      #srv.vm.provision "shell", :path => machine['script'], 
      srv.vm.provision "shell" do |shell|
        shell.path = machine['script']
        shell.args = machine['zecversion']      
      end

      # Configure VMs with RAM and CPUs per machines.yml (Fusion)
      srv.vm.provider 'vmware_fusion' do |vmw|
        vmw.vmx['memsize'] = machine['ram']
        vmw.vmx['numvcpus'] = machine['vcpu']
      end # srv.vm.provider vmware_fusion

      # Configure the VM with RAM and CPUs per machines.yml (VirtualBox)
      srv.vm.provider 'virtualbox' do |vb, override|
        vb.memory = machine['ram']
        vb.cpus = machine['vcpu']
        override.vm.box = machine['vb_box']
      end # srv.vm.provider virtualbox
    end # config.vm.define
  end # machines.each
end # Vagrant.configure