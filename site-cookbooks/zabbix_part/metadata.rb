name             'zabbix_part'
version          '0.0.1'
description      'Installs/Configures zabbix server ant agent'
license          'Apache v2.0'
maintainer       'TIS Inc.'
maintainer_email 'ccndctr@gmail.com'

supports 'ubuntu', '>= 10.04'
supports 'debian', '>= 6.0'
supports 'redhat', '>= 5.0'
supports 'centos', '>= 5.0'
supports 'oracle', '>= 5.0'
supports 'windows'
depends 'apache2', '>= 1.0.8'
depends 'database', '>= 1.3.0'
depends 'mysql', '>= 1.3.0'
depends 'ufw', '>= 0.6.1'
depends 'yum'
depends 'postgresql'
depends 'php-fpm'
depends 'nginx', '>= 1.0.0'
depends 'ark', '>= 0.7.2'
depends 'chocolatey'
depends 'java'
depends 'oracle-instantclient'
depends 'php'
depends 'yum-epel'
depends 'mysql-chef_gem'
