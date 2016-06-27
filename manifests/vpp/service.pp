# == Class fdio::vpp::service
#
# Starts the VPP systemd or Upstart service.
#
class fdio::vpp::service {
  service { 'vpp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
