CHANGELOG
=========

## version 1.1.0 (2015/09/30)
  - Support CloudConductor v1.1.
  - Remove the event_handler.sh, modified to control by the Metronome (task order control tool).Therefore, add the requirements(task.yml file etc.) to control from the Metronome.
  - Remove cloud_conductor_util gem from the required gems.
  - Add the requirements for test run in test-kitchen.
  - Add the JMX monitor discovery.
  - Support Zabbix-web multi language.
  - Add attach template to zabbix.

## version 1.0.0 (2015/03/27)

  - Support CloudConductor v1.0.

## version 0.3.2 (2014/12/24)

  - Support latest serverspec.
  - Add default CIDR to CloudConductorLocation parameter.
  - Remove unnecessary role file.
  - Delete spec for windows platform, because it do not possible to the test on linux.
  - Brush up a chef recipe on zabbix_part.

## version 0.3.0 (2014/10/31)

  - First release of this pattern that contains zabbix
