name             'zabbix_part'
version          '0.0.1'
description      'Installs/Configures zabbix server ant agent'
license          'Apache v2.0'
maintainer       'TIS Inc.'
maintainer_email 'ccndctr@gmail.com'

supports         'centos', '= 6.5'

depends          'yum-epel'
depends          'zabbix'
depends          'database', '= 2.3.1'
depends          'mysql'
depends          'apache2'
