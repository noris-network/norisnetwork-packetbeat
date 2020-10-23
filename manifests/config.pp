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

  $validate_cmd = $packetbeat::disable_configtest ? {
    true => undef,
    default => "${packetbeat_bin} test config -c %",
  }

  $packetbeat_config = delete_undef_values({
    'name'                      => $packetbeat::beat_name ,
    'fields_under_root'         => $packetbeat::fields_under_root,
    'fields'                    => $packetbeat::fields,
    'tags'                      => $packetbeat::tags,
    'queue'                     => $packetbeat::queue,
    'logging'                   => $packetbeat::logging,
    'output'                    => $packetbeat::outputs,
    'processors'                => $packetbeat::processors,
    'setup'                     => $packetbeat::setup,
    'packetbeat'                => {
      'flows'                     => $packetbeat::flows,
      'protocols'                 => $packetbeat::protocols,
      'procs'                     => $packetbeat::procs,
      'interfaces'                => $interfaces_hash,
    },
  })

  if ($packetbeat::xpack != undef) and ($packetbeat::monitoring != undef) {
    fail('Setting both xpack and monitoring is not supported!')
  }

  # Add the 'xpack' section if supported (version >= 6.2.0)
  if ((versioncmp($packetbeat::package_ensure, '7.2.0') >= 0) or $packetbeat::package_ensure == 'present') and ($packetbeat::monitoring) {
    $merged_config = deep_merge($packetbeat_config, {'monitoring' => $packetbeat::monitoring})
  }
  elsif (versioncmp($packetbeat::package_ensure, '6.2.0') >= 0) and ($packetbeat::xpack) {
    $merged_config = deep_merge($packetbeat_config, {'xpack' => $packetbeat::xpack})
  }
  else {
    $merged_config = $packetbeat_config
  }

  file { '/etc/packetbeat/packetbeat.yml':
    ensure       => $packetbeat::ensure,
    owner        => 'root',
    group        => 'root',
    mode         => $packetbeat::config_file_mode,
    content      => inline_template('<%= @merged_config.to_yaml()  %>'),
    validate_cmd => $validate_cmd,
  }
}
