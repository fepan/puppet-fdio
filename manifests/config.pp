# == Class fdio::config
#
# This class handles vpp config changes.
#
class fdio::config (
  $dpdk_pmd_type = $::fdio::params::dpdk_pmd_type,
){
  file_line { 'startup.conf':
    path  => '/etc/vpp/startup.conf',
    line  => "cli-listen localhost:${fdio_port}",
    after => '^unix.*$',
  }

  file_line { 'startup.conf':
    path  => '/etc/vpp/startup.conf',
    line  => "    uio-driver ${dpdk_pmd_type}",
    after => '^    uio-driver.*$',
  }

  # ensure that uio-pci-generic is loaded
  exec { 'modprobe uio-pci-generic':
    unless => 'lsmod | grep uio-pci-generic',
  }
}
