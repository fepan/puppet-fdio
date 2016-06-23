# == Class fdio::service
#
# Starts the VPP systemd or Upstart service.
#
class fdio::service {
  service { 'vpp':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  service { 'honeycomb':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

