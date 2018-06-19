# Class: packetbeat
# ================
#
# * `beat_name`: 
# [String] the name of the shipper (default: the *hostname*).
#
# * `fields_under_root`: 
# [Boolean] whether to add the custom fields to the root of the document (default is *false*).
#
# * `queue`: 
# [Hash] packetbeat's internal queue, before the events publication (default is *4096* events in *memory* with immediate flush).
#
# * `logging`: 
# [Hash] the packetbeat's logfile configuration (default: writes to `/var/log/packetbeat/packetbeat`, 
# maximum 7 files, rotated when bigger than 10 MB).
#
# * `flows`: 
# [Hash] the configuration for the monitoring of network flows (enabled by default, reporting period 10 seconds, 
# timeout set to 30 seconds).
#
# * `interfaces`: 
# [Hash] the interface(s) used to capture the traffic (default ist 'any', sniffing mode is 'pcap'). Please read 
# the [documentation] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-interfaces.html) for 
# the details.
# 
# * `queue_size`: 
# [Integer] the internal queue size for single events in the processing pipeline, applicable only if the major 
# version is '5' (default: 1000).
# 
# * `outputs`: 
# [Hash] the options of the mandatory [outputs] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuring-output.html) section of the configuration file (default: undef).
#
# * `major_version`: 
# [Enum] the major version of the package to install (default: '6').
#
# * `ensure`: 
# [Enum 'present', 'absent']: whether Puppet should manage `packetbeat` or not (default: 'present').
#
# * `service_provider`: 
# [Enum 'systemd', 'init'] which boot framework to use to install and manage the service (default: 'systemd').
#
# ' `manage_repo`:
# [Boolean] whether to configure the Elastic package repo or not (default: true).
#
# * `service_ensure`: 
# [Enum 'enabled', 'running', 'disabled', 'unmanaged'] the status of the packet service (default 'enabled'). In more details:
#     * *enabled*: service is running and started at every boot;
#     * *running*: service is running but not started at boot time;
#     * *disabled*: service is not running and not started at boot time;
#     * *unamanged*: Puppet does not manage the service.
#
# * `package_ensure`: 
# [String] the package version to install. It could be 'latest' (for the newest release) or a specific version 
# number, in the format *x.y.z*, i.e., *6.2.0* (default: latest).
#
# * `config_file_mode`: 
# [String] the octal file mode of the configuration file `/etc/packetbeat/packetbeat.yml` (default: 0644).
#
# * `disable_configtest`: 
# [Boolean] whether to check if the configuration file is valid before attempting to run the 
# service (default: true).
#
# * `tags`: 
# [Array[Strings]]: the tags to add to each document (default: undef).
#
# * `fields`: 
# [Hash] the fields to add to each document (default: undef).
#
# * `protocols`: 
# [Hash] the tansaction protocols to monitor (default: undef). Please refer to the [documentation] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-protocols.html) for the available options.
#
# * `modules`: 
# [Array[Hash]] the required [modules] (https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-modules.html) to load (default: undef).
#
# * `processors`: 
# [Array[Hash]] the optional [processors] (https://www.elastic.co/guide/en/beats/packetbeat/current/defining-processors.html) for event enhancement (default: undef).
#
# * `procs`:
# [Hash] the optional section to monitor the [process tracking] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-processes.html) (default: undef).
#
# * `xpack`:
# [Hash] the configuration of x-pack monitoring (default: undef).
#
# Examplses
# ================
#
# @example
#
# class{'packetbeat':
#     interfaces => {
#       'device' => 'eth0'
#     },
#     protocols => {
#       'http' => {
#         'ports' => [80, 8080]
#       },
#       'tls' => {
#         'ports' => [443]
#       },
#     },
#     outputs => {
#       'elasticsearch' => {
#         'hosts' => ['http://localhost:9200'],
#         'index' => 'packetbeat-%{+YYYY.MM.dd}',
#       },
#     },


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
  Hash $interfaces                                                    = {},
  Integer $queue_size                                                 = 1000,
  Hash $outputs                                                       = {},
  Enum['5', '6'] $major_version                                       = '6',
  Enum['present', 'absent'] $ensure                                   = 'present',
  Enum['systemd', 'init'] $service_provider                           = 'systemd',
  Boolean $manage_repo                                                = true,
  Enum['enabled', 'running', 'disabled', 'unmanaged'] $service_ensure = 'enabled',
  String $package_ensure                                              = 'latest',
  String $config_file_mode                                            = '0644',
  Boolean $disable_configtest                                         = false,
  Optional[Array[String]] $tags                                       = undef,
  Optional[Hash] $fields                                              = undef,
  Optional[Hash] $protocols                                           = undef,
  Optional[Array[Hash]] $processors                                   = undef,
  Optional[Hash] $procs                                               = undef,
  Optional[Hash] $xpack                                               = undef,
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
