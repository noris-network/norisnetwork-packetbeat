# packetbeat::params
# @api private
#
# @summary: default values for some parameterssome parameters
class packetbeat::params {
  $interfaces = {
    'device' => 'any',
    'type' => 'pcap',
    'snaplen' => 65535,
    'buffer_size_mb' => 30,
    'with_vlans' => true,
    'bpf_filter' => '',
    'ignore_outgoing' => false,
  }
}
