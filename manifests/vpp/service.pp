# == Class fdio::vpp::service
#
# Starts the VPP systemd or Upstart service.
#
class fdio::vpp::service (
  $dpdk_pci_devs = $::fdio::params::dpdk_pci_devs,
  $nic_names = $::fdio::params::nic_names,
  $ipaddresses = $::fdio::params::ipaddresses,
){

  define shutdown_nic ($nic_name = $title) {
    exec { "shut down nic $nic_name":
      command => "ip link set dev $nic_name down",
      notify  => Service['vpp'],
      onlyif  => "ip link show $nic_name | grep 'state UP' > /dev/null",
      path    => '/usr/sbin:/usr/bin',
    }
  }

  shutdown_nic { $nic_names: }

  service { 'vpp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  vpp_interface_cfg { "config vpp interfaces" :
    interfaces => $dpdk_pci_devs,
    state      => "up",
    ipaddress  => $ipaddresses,
    require    => Service['vpp'],
  }
  
}

