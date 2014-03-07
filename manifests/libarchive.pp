class razor::libarchive {
  $libarchive_package = $operatingsystem ? {
    "Ubuntu" => $operatingsystemrelease ? {
      /^12/   => 'libarchive12',
      /^13/   => 'libarchive13',
      default => undef
    },
    "Debian" => $operatingsystemmajrelease ? {
      '6'     => 'libarchive1',
      '7'     => 'libarchive12',
      default => 'libarchive13'
    },
    # We need the unversioned .so, which comes from the dev package on these
    # platforms; without that FFI fails to load the library.  This naturally
    # depends on the regular library package in yum.
    "Fedora" => 'libarchive-devel',
    "RedHat" => 'libarchive-devel',
    "CentOS" => 'libarchive-devel',
    default  => undef
  }

  if ! $libarchive_package {
    fail("unable to autodetect libarchive package name for your platform")
  }

  package { $libarchive_package: ensure => latest }
}
