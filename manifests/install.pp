# == Class fdio::install
#
# Manages the installation of fdio.
#
class fdio::install {
  if $fdio::install_method == 'rpm' {
    $base_url = $fdio::rpm_repo ? {
      'release' => 'https://nexus.fd.io/content/repositories/fd.io.centos7/',
      'master'  => 'https://nexus.fd.io/content/repositories/fd.io.master.centos7/',
      default   => "https://nexus.fd.io/content/repositories/fd.io.${fdio::rpm_repo}.centos7/",
    }

    # Add fdio's Yum repository
    yumrepo { "fdio-$fdio::rpm_repo":
      baseurl  => $base_url,
      descr    => "FD.io ${fdio::rpm_repo} packages",
      enabled  => 1,
      gpgcheck => 0,
    }

    # Install the VPP RPM
    package { 'vpp':
      ensure  => present,
      require => Yumrepo["fdio-$fdio::rpm_repo"],
    }
  }
  else {
    fail("Unsupported install method: ${fdio::install_method}")
  }
}
