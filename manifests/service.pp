# == Class fdio::service
#
# Starts the FDIO systemd or Upstart service.
#
class fdio::service {

  define shutdown_nic ($nic_name = $title) {
    exec { "shut down nic $nic_name":
      command => "ip link set dev $nic_name down",
      notify  => Service['vpp'],
      onlyif  => "ip link show $nic_name | grep 'state UP' > /dev/null",
      path    => '/usr/sbin:/usr/bin',
    }
    file_line { "ifcfg-$nic_name":
      path  => "/etc/sysconfig/network-scripts/ifcfg-$nic_name",
      line  => "ONBOOT=no",
      match => "ONBOOT=.*",
    }
  }

  shutdown_nic { $::fdio::fdio_nic_names: }

  service { 'vpp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  vpp_interface_cfg { "config vpp interfaces" :
    interfaces => $::fdio::fdio_dpdk_pci_devs,
    state      => "up",
    ipaddress  => $::fdio::fdio_ips,
    require    => Service['vpp'],
  }
  
}

