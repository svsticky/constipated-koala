# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = 'ubuntu/trusty64'
  config.vm.hostname = 'trusty-koala'

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks']

    chef.add_recipe 'apt'
    chef.add_recipe 'vim'
    chef.add_recipe 'nodejs'

    chef.add_recipe 'ruby_build'
    chef.add_recipe 'imagemagick'

    chef.add_recipe 'rbenv::user'
    chef.add_recipe 'rbenv::vagrant'

    chef.add_recipe 'mysql::server'
    chef.add_recipe 'mysql::client'

    # Install Ruby 2.3.0 and Bundler
    # Set an empty root password for MySQL to make things simple
    chef.json = {
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ['2.4.1'],
          global: '2.4.1',
          plugins: [
            {
              'name' => 'rbenv-vars',
              'git_url' => 'https://github.com/sstephenson/rbenv-vars.git'
            },
            {
              'name' => 'rbenv-gem-rehash',
              'git_url' => 'https://github.com/sstephenson/rbenv-gem-rehash.git'
            }
          ]
        }]
      },
      mysql: {
        server_root_password: ''
      }
    }
  end
end
