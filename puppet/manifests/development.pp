# development.pp
stage { 'req-install': before => Stage['rvm-install'] }

class requirements {
  group { "puppet": ensure => "present", }

  ### TODO ПЛОХОЙ КОД!!!
  ### use google: puppet apt
  exec { "rename-sources-list":
    command => "/bin/mv /etc/apt/sources.list /etc/apt/sources.list.dist"
  }

  exec { "wget-sources-list":
    command => "/usr/bin/wget http://bediev.com/work/sources.list.precise -O /etc/apt/sources.list",
    require => Exec['rename-sources-list']
  }
  ###

  exec { "apt-update":
    # command => "/usr/bin/apt-get update -y && /usr/bin/apt-get dist-upgrade -y",
    command => "/usr/bin/apt-get update -y",
    require => Exec['wget-sources-list']
  }

  package {
    ["mysql-client", "nodejs", "libmysqlclient-dev"]: 
      ensure => installed, require => Exec['apt-update']
  }
}

class installmysql {
  class { 'mysql::server':
    config_hash => { 'root_password' => 'foo' }
  }

  mysql::db { 'mydb':
    user     => 'myuser',
    password => 'mypass',
    host     => 'localhost',
    grant    => ['all'],
  }
}

class installnginx {
  class { 'nginx': }
}

class installrvm {
  include rvm
  rvm::system_user { vagrant: ; }

  rvm_system_ruby {
    'ruby-1.9.3-p327':
    ensure      => 'present'
  }

  rvm_gemset {
    "ruby-1.9.3-p327@test_app":
    ensure => present,
    require => Rvm_system_ruby['ruby-1.9.3-p327'];
  }
}

class doinstall {
  class { requirements:, stage => "req-install" }
  include installnginx
  include installmysql
  include installrvm
}

include doinstall
