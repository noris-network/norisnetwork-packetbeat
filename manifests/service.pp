# packetbeat::service
# @api private
#
# @summary It manages the packetbeat service
class packetbeat::service {
  if $packetbeat::ensure == 'present' {
    case $packetbeat::service_ensure {
      'enabled': {
        $service_status = 'running'
        $service_enabled = true
      }
      'disabled': {
        $service_status = 'stopped'
        $service_enabled = false
      }
      'running': {
        $service_status = 'running'
        $service_enabled = false
      }
      'unmanaged': {
        $service_status = undef
        $service_enabled = false
      }
      default: {}
    }
  }
  else {
    $service_status = 'stopped'
    $service_enabled = false
  }

  service {'packetbeat':
    ensure   => $service_status,
    enable   => $service_enabled,
    provider => $packetbeat::service_provider,
  }
}
