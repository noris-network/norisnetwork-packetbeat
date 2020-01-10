# packetbeat::repo
# @api private
#
# @summary Manages the package repositories on the target nodes to install packetbeat
class packetbeat::repo inherits packetbeat {
  $apt_repo_url = $packetbeat::apt_repo_url ? {
    undef => "https://artifacts.elastic.co/packages/${packetbeat::major_version}.x/apt",
    default => $packetbeat::apt_repo_url,
  }
  $yum_repo_url = $packetbeat::yum_repo_url ? {
    undef => "https://artifacts.elastic.co/packages/${packetbeat::major_version}.x/yum",
    default => $packetbeat::yum_repo_url,
  }
  $gpg_key_url = $packetbeat::gpg_key_url ? {
    undef => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
    default => $packetbeat::gpg_key_url,
  }

  if ($packetbeat::manage_repo == true) and ($packetbeat::ensure == 'present') {
    case $facts['osfamily'] {
      'Debian': {
        include ::apt
        if !defined(Apt::Source['beats']) {
          apt::source{'beats':
            ensure   => $packetbeat::ensure,
            location => $apt_repo_url,
            release  => 'stable',
            repos    => 'main',
            key      => {
              id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
              source => $gpg_key_url,
            },
          }
          Class['apt::update'] -> Package['packetbeat']
        }
      }
      'RedHat': {
        if !defined(Yumrepo['beats']) {
          yumrepo{'beats':
            ensure   => $packetbeat::ensure,
            descr    => "Elastic repository for ${packetbeat::major_version}.x packages",
            baseurl  => $yum_repo_url,
            gpgcheck => 1,
            gpgkey   => $gpg_key_url,
            enabled  => 1,
          }
        }
      }
      'SuSe': {
        exec { 'topbeat_suse_import_gpg':
          command => '/usr/bin/rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          unless  => '/usr/bin/test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
          notify  => [ Zypprepo['beats'] ],
        }
        if !defined (Zypprepo['beats']) {
          zypprepo{'beats':
            baseurl     => $yum_repo_url,
            enabled     => 1,
            autorefresh => 1,
            name        => 'beats',
            gpgcheck    => 1,
            gpgkey      => $gpg_key_url,
            type        => 'yum',
          }
        }
      }
      default: {
      }
    }
  }
}
