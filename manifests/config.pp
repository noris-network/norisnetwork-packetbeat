# packetbeat::config
# @api private
#
# @summary It configures the packetbeat shipper
class packetbeat::config {
  contain packetbeat::params
  $packetbeat_bin = '/usr/share/packetbeat/bin/packetbeat'

  $interfaces_merged = deep_merge($packetbeat::params::interfaces, $packetbeat::interfaces)
  case $interfaces_merged['type'] {
    'pcap': {
      $interfaces_hash = delete($interfaces_merged, ['buffer_size_mb', 'with_vlans', 'ignore_outgoing', 'bpf_filter'])
    }
    default: {
      $interfaces_hash = $interfaces_merged
    }
  }

  case $packetbeat::major_version {
    '5': {
      $packetbeat_config = delete_undef_values({
        'name'                      => $packetbeat::beat_name ,
        'fields_under_root'         => $packetbeat::fields_under_root,
        'fields'                    => $packetbeat::fields,
        'tags'                      => $packetbeat::tags,
        'queue_size'                => $packetbeat::queue_size,
        'logging'                   => $packetbeat::logging,
        'output'                    => $packetbeat::outputs,
        'processors'                => $packetbeat::processors,
        'packetbeat'                => {
          'flows'                     => $packetbeat::flows,
          'protocols'                 => $packetbeat::protocols,
          'procs'                     => $packetbeat::procs,
          'interfaces'                => $interfaces_hash,
        },
      })
      $validate_cmd_temp = "${packetbeat_bin} -N -configtest -c %"
    }
    default: {
      $packetbeat_config_temp = delete_undef_values({
        'name'                      => $packetbeat::beat_name ,
        'fields_under_root'         => $packetbeat::fields_under_root,
        'fields'                    => $packetbeat::fields,
        'tags'                      => $packetbeat::tags,
        'logging'                   => $packetbeat::logging,
        'queue'                     => $packetbeat::queue,
        'output'                    => $packetbeat::outputs,
        'processors'                => $packetbeat::processors,
        'packetbeat'                => {
          'flows'                     => $packetbeat::flows,
          'protocols'                 => $packetbeat::protocols,
          'procs'                     => $packetbeat::procs,
          'interfaces'                => $interfaces_hash,
        },
      })
      $validate_cmd_temp = "${packetbeat_bin} test config -c %"
      case $packetbeat::package_ensure {
        'latest': { $packetbeat_config = deep_merge($packetbeat_config_temp, {'xpack' => $packetbeat::xpack}) }
        /^\w+$/:  { $packetbeat_config = $packetbeat_config_temp }
        default:  {
          if versioncmp($packetbeat::package_ensure, '6.1.0') >= 0 {
            $packetbeat_config = deep_merge($packetbeat_config_temp, {'xpack' => $packetbeat::xpack})
          }
          else {
            $packetbeat_config = $packetbeat_config_temp
          }
        }
      }
    }
  }

  $validate_cmd = $packetbeat::disable_configtest ? {
    true => undef,
    default => $validate_cmd_temp,
  }

  file { '/etc/packetbeat/packetbeat.yml':
    ensure       => $packetbeat::ensure,
    owner        => 'root',
    group        => 'root',
    mode         => $packetbeat::config_file_mode,
    content      => inline_template('<%= @packetbeat_config.to_yaml()  %>'),
    validate_cmd => $validate_cmd,
  }
}
