class apt_update {
    exec { "aptGetUpdate":
        command => "sudo apt-get update",
        path => ["/bin", "/usr/bin"]
    }
}

class othertools {
    package { "git":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "vim-common":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "curl":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }

    package { "htop":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }

    package { "g++":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }

}

class nodejs {
  exec { "git_clone_n":
    command => "git clone https://github.com/visionmedia/n.git /home/vagrant/n",
    path => ["/bin", "/usr/bin"],
    require => [Exec["aptGetUpdate"], Package["git"], Package["curl"], Package["g++"]]
  }

  exec { "install_n":
    command => "make install",
    path => ["/bin", "/usr/bin"],
    cwd => "/home/vagrant/n",
    require => Exec["git_clone_n"]
  }

  exec { "install_node":
    command => "n stable",
    path => ["/bin", "/usr/bin", "/usr/local/bin"],  
    require => [Exec["git_clone_n"], Exec["install_n"]]
  }
}

class nginx {
  package { "nginx":
      ensure => installed
  }

  service { "nginx":
      require => Package["nginx"],
      ensure => running,
      enable => true
  }

  file { "/etc/nginx/sites-available/somehub.dev":
      require => [
          Package["nginx"],
      ],
      ensure => "file",
      content => 
          '
          upstream somehub_dev {
              server 127.0.0.1:3001;
              keepalive 8;
          }

          # the nginx server instance
          server {
              listen 0.0.0.0:80;
              server_name somehub.dev;
              access_log /var/log/nginx/somehubdev.log;

              location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;

                proxy_pass http://somehub_dev/;
                proxy_redirect off;
              }
           }',
      notify => Service["nginx"]
  }
  file { "/etc/nginx/sites-enabled/somehub.dev":
      require => File["/etc/nginx/sites-available/somehub.dev"],
      ensure => "link",
      target => "/etc/nginx/sites-available/somehub.dev",
      notify => Service["nginx"]
  }

}

file { "/etc/nginx/sites-enabled/default":
    require => Package["nginx"],
    ensure  => absent,
    notify  => Service["nginx"]
}

class mongodb {
  class {'::mongodb::globals':
    manage_package_repo => true,
    bind_ip             => ["0.0.0.0"],
  }->
  class {'::mongodb::server':
    port    => 27017,
    verbose => true,
    ensure  => "present"
  }->
  class {'::mongodb::client': }
}

class redis-cl {
  class { 'redis': }
}

include apt_update
include othertools
include nodejs
include nginx
include mongodb
include redis-cl
