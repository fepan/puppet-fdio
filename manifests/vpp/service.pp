# == Class fdio::vpp::service
#
# Starts the VPP systemd or Upstart service.
#
class fdio::vpp::service (
  $dpdk_pci_devs = $::fdio::params::dpdk_pci_devs,
){
  define intf_down ($pci_addr = $title) {
    $interface_name = inline_template("<%= `ls /sys/bus/pci/devices/$pci_addr/*/net`.chomp %>")

    if  $interface_name {
      $interface_ip_var = "ipaddress_$interface_name"
      $interface_ip = inline_template("<%= scope.lookupvar(interface_ip_var) %>")
      $interface_netmask_var = "netmask_$interface_name"
      $interface_cidr = inline_template("<%= require 'ipaddr'; IPAddr.new(scope.lookupvar(interface_netmask_var)).to_i.to_s(2).count('1') %>")

      $interface_speed = inline_template("<%= `cat /sys/bus/pci/devices/$pci_addr/*/net/$interface_name/speed`.chomp %>")
      if $interface_speed and $interface_speed == "10000" {
        $vpp_int_prefix = 'TenGigabitEthernet'
      } else {
        $vpp_int_prefix = 'GigabitEthernet'
      }

      $pci_addr_parts = split($pci_addr, '[.:]')
      $bus_id = "0x${pci_addr_parts[1]}" + 0
      $dev_id = "0x${pci_addr_parts[2]}" + 0
      $func_id = "0x${pci_addr_parts[3]}" + 0
      $vpp_interface_name = "${vpp_int_prefix}$bus_id/$dev_id/$func_id"

      exec {"shut down interface $interface_name":
        command => "/usr/sbin/ip link set dev ${interface_name} down",
        notify  => Service['vpp'],
        onlyif  => "/usr/bin/grep up /sys/class/net/${interface_name}/operstate",
      }
      exec { "apply interface ip for $vpp_interface_name":
        command => "vppctl set int ip address $vpp_interface_name $interface_ip/$interface_cidr",
        require => Service['vpp'],
        unless  => "vppctl show int address $vpp_interface_name | grep $interface_ip/$interface_cidr",
        path    => '/usr/bin',
      }->
      exec { "bring interface $vpp_interface_name up":
        command => "vppctl set interface state $vpp_interface_name up",
        unless  => "vppctl show interface $vpp_interface_name | grep up",
        path    => '/usr/bin',
      }
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

