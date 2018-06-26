# packetbeat


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with packetbeat](#setup)
    * [What packetbeat affects](#what-packetbeat-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with packetbeat](#beginning-with-packetbeat)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures the [Packetbeat shipper](https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-overview.html) by Elastic. It has been tested on Puppet 5.x and on the following OSes: Debian 9.1, CentOS 7.3, Ubuntu 16.04

## Setup

### What packetbeat affects

`packetbeat` configures the package repository to fetch the software, it installs it, it configures both the application (`/etc/packetbeat/packetbeat.yml`) and the service (`systemd` by default, but it is possible to manually switch to `init`) and it takes care that it is running and enabled.

### Setup Requirements

`packetbeat` needs `puppetlabs/stdlib`, `puppetlabs/apt` (for Debian and derivatives), `puppet/yum` (for RedHat or RedHat-like systems), `darin-zypprepo` (on SuSE based system)

### Beginning with packetbeat

The module can be installed manually, typing `puppet module install noris-packetbeat`, or by means of an environment manager (r10k, librarian-puppet, ...).

`packetbeat` requires at least the `outputs` and section in order to start. Please refer to the software documentation to find out the [supported outputs] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuring-output.html). On the other hand, the sections [logging] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-logging.html) and [queue] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuring-internal-queue.html) already contains meaningful default values. The module also configures the listening [interfaces] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-interfaces.html) (`any` is the given value and the sniffing mechanism is `pcap`) and it enable the [flows collection] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-flows.html). The specific [transaction protocols] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-protocols.html) to monitor should be explicitly configured.

A basic setup capturing the HTTP traffic from port 80 on the ethernet interface writing the results directly in Elasticsearch.

```puppet
class{'packetbeat':
    interfaces => {
      'device' => 'eth0',
    },
    protocols => {
      'http' => {
        'ports' => [80],
      }
    },
    outputs => {
      'elasticsearch' => {
        'hosts' => ['http://localhost:9200'],
        'index' => 'packetbeat-%{+YYYY.MM.dd}',
      },
    },
```
The same example, but using Hiera

```
classes:
  include:
    - 'packetbeat'

packetbeat::interfaces:
  device: 'eth0'
packetbeat::protocols:
  http:
    ports:
      - 80
packetbeat::outputs:
  elasticsearch:
    hosts: 
      - 'http://localhost:9200'
    index: "packetbeat-%%{}{+YYYY.MM.dd}"
```

## Usage

The configuration is written to the configuration file `/etc/packetbeat/packetbeat.yml` in yaml format. The default values follow the upstream (as of the time of writing).

Send data to two Redis servers, loadbalancing between the instances.

```puppet
class{'packetbeat':
    interfaces => {
      'device' => 'eth0',
    },
    protocols => {
      'http' => {
        'ports' => [80],
      }
    },
    outputs => {
      'redis' => {
        'hosts' => ['localhost:6379', 'other_redis:6379'],
        'key' => 'packetbeat',
      },
    },
```
If using Hiera, the above example would look like

```
classes:
  include:
    - 'packetbeat'

packetbeat::interfaces:
  device: 'eth0'
packetbeat::protocols:
  http:
    ports:
      - 80
packetbeat::outputs:
  redis:
    hosts: 
      - 'localhost:6379'
      - 'other_redis:6379'
    key: "packetbeat"
```
Add the `packetd` module to the configuration, specifying a rule to detect 32 bit system calls. Output to Elasticsearch.
Disable flow detection, detect HTTP traffic on port 8080 too and use `af_packet` to capture the traffic. Output to Elasticsearch.

```puppet
class{'packetbeat':
    interfaces => {
      'device' => 'eth0',
      'type' => 'af_packet',
    },
    flows => {
      'enabled' => false,
    },
    protocols => {
      'http' => {
        'ports' => [80, 8080],
      }
    },
    outputs => {
      'elasticsearch' => {
        'hosts' => ['http://localhost:9200'],
        'index' => 'packetbeat-%{+YYYY.MM.dd}',
      },
    },
```
Similarly, in Hiera

```
classes:
  include:
    - 'packetbeat'

packetbeat::interfaces:
  device: 'eth0'
  type: 'af_packet'
packetbeat::flows:
  enabled: false
packetbeat::protocols:
  http:
    ports:
      - 80
      - 8080
packetbeat::outputs:
  elasticsearch:
    hosts: 
      - 'http://localhost:9200'
    index: "packetbeat-%%{}{+YYYY.MM.dd}"
```


## Reference

* [Public Classes](#public-classes)
	* [Class: packetbeat](#class-packetbeat)
* [Private Classes](#private-classes)
	* [Class: packetbeat::repo](#class-packetbeat-repo)
	* [Class: packetbeat::install](#class-packetbeat-install)
	* [Class: packetbeat::config](#class-packetbeat-config)
	* [Class: packetbeat::service](#class-packetbeat-service)


### Public Classes

#### Class: `packetbeat`

Installation and configuration.

**Parameters**:

* `beat_name`: [String] the name of the shipper (default: the *hostname*).
* `fields_under_root`: [Boolean] whether to add the custom fields to the root of the document (default is *false*).
* `queue`: [Hash] packetbeat's internal queue, before the events publication (default is *4096* events in *memory* with immediate flush).
* `logging`: [Hash] the packetbeat's logfile configuration (default: writes to `/var/log/packetbeat/packetbeat`, maximum 7 files, rotated when bigger than 10 MB).
* `flows`: [Hash] the configuration for the monitoring of network flows (enabled by default, reporting period 10 seconds, timeout set to 30 seconds).
* `interfaces`: [Hash] the interface(s) used to capture the traffic (default ist 'any', sniffing mode is 'pcap'). Please read the [documentation] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-interfaces.html) for the details.
* `queue_size`: [Integer] the internal queue size for single events in the processing pipeline, applicable only if the major version is '5' (default: 1000).
* `outputs`: [Hash] the options of the mandatory [outputs] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuring-output.html) section of the configuration file (default: undef).
* `major_version`: [Enum] the major version of the package to install (default: '6').
* `ensure`: [Enum 'present', 'absent']: whether Puppet should manage `packetbeat` or not (default: 'present').
* `service_provider`: [Enum 'systemd', 'init'] which boot framework to use to install and manage the service (default: 'systemd').
' `manage_repo`: [Boolean] whether to configure the Elastic package repo or not (default: true).
* `service_ensure`: [Enum 'enabled', 'running', 'disabled', 'unmanaged'] the status of the packet service (default 'enabled'). In more details:
    * *enabled*: service is running and started at every boot;
    * *running*: service is running but not started at boot time;
    * *disabled*: service is not running and not started at boot time;
    * *unamanged*: Puppet does not manage the service.
* `package_ensure`: [String] the package version to install. It could be 'latest' (for the newest release) or a specific version number, in the format *x.y.z*, i.e., *6.2.0* (default: latest).
* `config_file_mode`: [String] the octal file mode of the configuration file `/etc/packetbeat/packetbeat.yml` (default: 0644).
* `disable_configtest`: [Boolean] whether to check if the configuration file is valid before attempting to run the service (default: true).
* `tags`: [Array[Strings]]: the tags to add to each document (default: undef).
* `fields`: [Hash] the fields to add to each document (default: undef).
* `protocols`: [Hash] the tansaction protocols to monitor (default: undef). Please refer to the [documentation] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-protocols.html) for the available options.
* `modules`: [Array[Hash]] the required [modules] (https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-modules.html) to load (default: undef).
* `processors`: [Array[Hash]] the optional [processors] (https://www.elastic.co/guide/en/beats/packetbeat/current/defining-processors.html) for event enhancement (default: undef).
* `procs`: [Hash] the optional section to monitor the [process tracking] (https://www.elastic.co/guide/en/beats/packetbeat/current/configuration-processes.html) (default: undef).
* `xpack`: [Hash] the configuration of x-pack monitoring (default: undef).


### Private Classes

#### Class: `packetbeat::repo`
Configuration of the package repository to fetch packetbeat.

#### Class: `packetbeat::install`
Installation of the packetbeat package.

#### Class: `packetbeat::config`
Configuration of the packetbeat daemon.

#### Class: `packetbeat::service`
Management of the packetbeat service.

#### Class: `packetbeat::params`
It defines the default values of some parameters.


## Limitations

This module does not load the index template in Elasticsearch nor the packetbeat example dashboards in Kibana. These two tasks should be carried out manually. Please follow the documentation to [manually load the index template in Elasticsearch] (https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-template.html#load-template-manually-alternate) and to [import the packetbeat dashboards in Kibana] (https://www.elastic.co/guide/en/beats/devguide/6.2/import-dashboards.html).

The option `manage_repo` does not work properly on SLES. This means that, even if set to *false*, the repo file 
`/etc/zypp/repos.d/beats.repo` will be created and the corresponding repo will be enabled.

The module allows to set up the 
[x-pack section] (https://www.elastic.co/guide/en/beats/packetbeat/current/monitoring.html) 
of the configuration file, in order to set the internal statistics of packetbeat to an Elasticsearch cluster. 
In order to do that the parameter `package_ensure` should be set to: 
* `latest`
* `6.1.0` or a higher version
Unfortunately when `package_ensure` is equal to `installed` or `present`, the `x-pack` section is removed, 
beacuse there is no way to know which version of the package is going to be handled (unless a specific fact is 
added).

## Development

Please feel free to report bugs and to open pull requests for new features or to fix a problem.
