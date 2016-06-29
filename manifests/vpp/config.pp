# == Class fdio::vpp::config
#
# This class handles vpp config changes.
#
class fdio::vpp::config (
  $dpdk_pmd_type = $::fdio::params::dpdk_pmd_type,
  $dpdk_pci_devs = $::fdio::params::dpdk_pci_devs,
){
  file_line { 'startup.conf_cli-listen':
    path  => '/etc/vpp/startup.conf',
    line  => "    cli-listen localhost:5002",
    after => '^unix.*$',
  }

  file_line { 'startup.conf_uio-driver':
    path  => '/etc/vpp/startup.conf',
    line  => "    uio-driver ${dpdk_pmd_type}",
    match => '.*uio-driver.*$',
  }

  each($dpdk_pci_devs) |$value| {
    file_line { "startup.conf_dev-$value":
      path  => '/etc/vpp/startup.conf',
      line  => "    dev ${value}",
      after => '^dpdk.*$',
    }
  }

  # ensure that uio-pci-generic is loaded
  exec { 'modprobe uio-pci-generic':
    unless => 'lsmod | grep uio-pci-generic',
    path   => '/bin:/sbin',
  }
}
