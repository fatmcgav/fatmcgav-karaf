# == Class karaf::params
#
# This class is meant to be called from karaf
# It sets variables according to platform
#
class karaf::params {
  case $::osfamily {
    'RedHat' : { $karaf_add_path = true }
    'Debian' : { $karaf_add_path = true }
    default  : { fail("${::osfamily} not supported") }
  }

  # Install method & location
  # Installation method. Can be: 'package','zip'.
  $karaf_install_method = 'zip'
  $karaf_install_dir    = undef

  # Default karaf temporary directory for downloading Zip.
  $karaf_tmp_dir        = '/tmp'

  # Version
  $karaf_version        = '3.0.1'

  # Should user be managed?
  $karaf_manage_user    = true
  $karaf_user           = 'karaf'
  $karaf_group          = 'karaf'

  # Default Karaf install parent directory.
  $karaf_parent_dir     = '/opt'

  # Download location
  $karaf_download_site  = "http://mirror.catn.com/pub/apache/karaf/${karaf_version}"
  $karaf_download_file  = "apache-karaf-${karaf_version}.tar.gz"

  # Should a karaf service be created on installation?
  # $karaf_create_service = true
  # Default karaf service name
  # $karaf_service_name   = undef
}
