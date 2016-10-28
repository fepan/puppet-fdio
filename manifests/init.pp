# == Class: fdio
#
# fd.io
#
# === Parameters
# [* fdio_port *]
#   Port for VPP to listen on.  Default 5002.
#
# [* dpdk_pmd_type *]
#   Sets VPP's DPDK poll-mode driver.  Default uio_pci_generic
#
# [* fdio_dpdk_pci_devs *]
#   Array of PCI addresses to bind to vpp.  Default None
#
# [* fdio_nic_names *]
#   Array of interface names for vpp to use.  Default None
#
# [* fdio_ips *]
#   Array of ip addresses for vpp to use.  Default None
#
# [* install_method *]
#   Installation method.  Default rpm
#
# [* rpm_repo *]
#   RPM repo branch, valid values are 'release', 'master', and stable branch such as 'stable.1609'.
#   Defaults to 'release'.
#
# [* vlan *]
#   Enabled vlan tagged traffic on VPP interfaces. This is needed to configure
#   vlan_strip_offload option for Cisco VIC interfaces.
#   Default to false.
#
# [* main_core *]
#   VPP main thread pinning. Default to '' (no pinning)
#
# [* corelist_workers *]
#   List of cores for VPP worker thread pinning in string format.
#   Default to '' (no pinning)
#
class fdio (
  $fdio_port          = $::fdio::params::fdio_port,
  $dpdk_pmd_type      = $::fdio::params::dpdk_pmd_type,
  $fdio_dpdk_pci_devs = $::fdio::params::fdio_dpdk_pci_devs,
  $fdio_nic_names     = $::fdio::params::fdio_nic_names,
  $fdio_ips           = $::fdio::params::fdio_ips,
  $install_method     = $::fdio::params::install_method,
  $rpm_repo           = $::fdio::params::rpm_repo,
  $vlan               = $::fdio::params::vlan,
  $main_core          = $::fdio::params::main_core,
  $corelist_workers   = $::fdio::params::corelist_workers,
) inherits ::fdio::params {

  # Validate OS family
  case $::osfamily {
    'RedHat': {}
    'Debian': {
        warning('Debian has limited support, is less stable, less tested.')
    }
    default: {
        fail("Unsupported OS family: ${::osfamily}")
    }
  }

  # Validate OS
  case $::operatingsystem {
    centos, redhat: {
      if $::operatingsystemmajrelease != '7' {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    fedora: {
      # Fedora distros < 22 are EOL as of 2015-12-01
      # https://fedoraproject.org/wiki/End_of_life
      if $::operatingsystemmajrelease < '22' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    ubuntu: {
      if $::operatingsystemmajrelease != '14.04' {
        # Only tested on 14.04
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  class { '::fdio::install': } ->
  class { '::fdio::config': } ~>
  class { '::fdio::service': } ->
  Class['::fdio']

}
