# packetbeat::install
# @api private
#
# @summary It installs the packetbeat package
class packetbeat::install {
  case $packetbeat::ensure {
    'present': {
      $package_ensure = $packetbeat::package_ensure
    }
    default: {
      $package_ensure = $packetbeat::ensure
    }
  }
  package{'packetbeat':
    ensure => $package_ensure,
  }
}
