# == Class fdio::config
#
# This class handles fdio config changes.
#
class fdio::config {
  file { '/etc/vpp/startup.conf':
    content => template('fdio/startup.conf.erb'),
  }

  # ensure that dpdk module is loaded
  exec { 'insert_dpdk_kmod':
    command => "modprobe ${::fdio::params::dpdk_pmd_type}",
    unless => "lsmod | grep ${::fdio::params::dpdk_pmd_type}",
    path   => '/bin:/sbin',
  }
}
