# == Class: fdio::vpp
#
# fd.io::vpp
#
# === Parameters
# [* vpp_port *]
#   Port for VPP to listen on.
# [* dpdk_pmd_driver *]
#   Sets VPP's uio-driver value
class fdio::vpp (
  $install_method = $::fdio::params::install_method,
  $vpp_port = $::fdio::params::vpp_rest_port,
  $dpdk_pmd_type = $::fdio::params::dpdk_pmd_type,
) inherits ::fdio {

  class { '::fdio::vpp::install':
    $install_method = $install_method,
  } ->
  class { '::fdio::vpp::config':
    $vpp_port = $::fdio::params::odl_rest_port,
    $dpdk_pmd_type = $dpdk_pmd_type,
  } ~>
  class { '::fdio::vpp::service': } ->
  Class['::fdio::vpp']
}
