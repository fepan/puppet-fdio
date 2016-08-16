# == Class fdio::vpp::service
#
# Starts the VPP systemd or Upstart service.
#
class fdio::vpp::service (
  $dpdk_pci_devs = $::fdio::params::dpdk_pci_devs,
){
  define intf_down ($pci_addr = $title) {
    $interface_name = inline_template("<%= `ls /sys/bus/pci/devices/$pci_addr/*/net`.chomp %>")
    exec {$interface_name:
      command => "/usr/sbin/ip link set dev ${interface_name} down",
      notify  => Service['vpp'],
      onlyif  => "/usr/bin/grep up /sys/class/net/${interface_name}/operstate",
    }
  }

  intf_down { $dpdk_pci_devs: }

  service { 'vpp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  # TODO
  #sudo vppctl set interface ip address TenGigabitEthernet7/0/0 192.168.21.21/24
  #sudo vppctl set interface state TenGigabitEthernet7/0/0 up
}

