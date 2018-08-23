# Installs and configures packetbeat
#
# @summary Installs and configures packetbeat
#
# @example a basic configuration using eth0 to capture http traffic (ports 80 and 8080) and TLS traffic (port 443)
#  class{'packetbeat':
#    interfaces => {
#      'device' => 'eth0'
#    },
#    protocols => {
#      'http' => {
#        'ports' => [80, 8080]
#      },
#      'tls' => {
#        'ports' => [443]
#      },
#    },
#    outputs => {
#      'elasticsearch' => {
#        'hosts' => ['http://localhost:9200'],
#        'index' => 'packetbeat-%{+YYYY.MM.dd}',
#      },
#    },
#  }
#
# @param beat_name the name of the shipper (defaults the hostname).
# @param fields_under_root whether to add the custom fields to the root of the document.
# @param queue packetbeat's internal queue, before the events publication.
# @param logging the packetbeat's logfile configuration.
# @param flows the configuration for the monitoring of network flows.
# @param interfaces interface(s) used to capture the traffic.
# @param queue_size the internal queue size for single events in the processing pipeline.
# @param outputs the options of the mandatory "outputs" section of the configuration file.
# @param major_version the major version of the package to install.
# @param ensure whether Puppet should manage packetbeat or not.
# @param service_provider which boot framework to use to manage the service.
# @param manage_repo whether to configure the Elastic package repo or not.
# @param service_ensure the status of the packetbeat service.
# @param package_ensure the package version to install.
# @param config_file_mode the permissions of the default configuration file.yml (default: 0644).
# @param disable_configtest whether to check if the configuration file is valid before running the service.
# @param tags the tags to add to each document.
# @param fields the fields to add to each document.
# @param protocols the tansaction protocols to monitor.
# @param processors the optional processors for events enhancement.
# @param procs the optional section to monitor the process tracking.
# @param xpack the configuration of x-pack monitoring.
#
class packetbeat (
  String $beat_name                                                   = $::hostname,
  Boolean $fields_under_root                                          = false,
  Hash $queue                                                         = {
    'mem' => {
      'events' => 4096,
      'flush' => {
        'min_events' => 0,
        'timeout' => '0s',
      },
    },
  },
  Hash $logging                                                       = {
    'level' => 'info',
    'selectors'  => undef,
    'to_syslog' => false,
    'to_eventlog' => false,
    'json' => false,
    'to_files' => true,
    'files' => {
      'path' => '/var/log/packetbeat',
      'name' => 'packetbeat',
      'keepfiles' => 7,
      'rotateeverybytes' => 10485760,
      'permissions' => '0600',
    },
    'metrics' => {
      'enabled' => true,
      'period' => '30s',
    },
  },
  Hash $flows                                                         = {
    'enabled' => true,
    'timeout' => '30s',
    'period' => '10s',
  },
  Hash $interfaces                                                                    = {},
  Integer $queue_size                                                                 = 1000,
  Hash $outputs                                                                       = {},
  Enum['5', '6'] $major_version                                                       = '6',
  Enum['present', 'absent'] $ensure                                                   = 'present',
  Optional[Enum['systemd', 'init', 'debian', 'redhat', 'upstart']] $service_provider  = undef,
  Boolean $manage_repo                                                                = true,
  Enum['enabled', 'running', 'disabled', 'unmanaged'] $service_ensure                 = 'enabled',
  String $package_ensure                                                              = 'latest',
  String $config_file_mode                                                            = '0644',
  Boolean $disable_configtest                                                         = false,
  Optional[Array[String]] $tags                                                       = undef,
  Optional[Hash] $fields                                                              = undef,
  Optional[Hash] $protocols                                                           = {},
  Optional[Array[Hash]] $processors                                                   = undef,
  Optional[Hash] $procs                                                               = {},
  Optional[Hash] $xpack                                                               = {},
) {

  contain packetbeat::repo
  contain packetbeat::install
  contain packetbeat::config
  contain packetbeat::service

  if $manage_repo {
    Class['packetbeat::repo']
    ->Class['packetbeat::install']
  }

  case $ensure {
    'present': {
      Class['packetbeat::install']
      ->Class['packetbeat::config']
      ~>Class['packetbeat::service']
    }
    default: {
      Class['packetbeat::service']
      ->Class['packetbeat::config']
      ->Class['packetbeat::install']
    }
  }
}
