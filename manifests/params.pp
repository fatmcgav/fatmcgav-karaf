# == Class karaf::params
#
# This class is meant to be called from karaf
# It sets variables according to platform
#
class karaf::params {
  # Need to manage Path? 
  case $::osfamily {
    'RedHat' : { $karaf_manage_path = true }
    'Debian' : { $karaf_manage_path = true }
    default  : { fail("${::osfamily} not supported") }
  }

  # Install method & location
  # Installation method. Can be: 'package','zip'.
  $karaf_install_method   = 'zip'
  $karaf_install_dir      = undef
  $karaf_start_on_install = true

  # Default karaf temporary directory for downloading Zip.
  $karaf_tmp_dir          = '/tmp'

  # Version
  $karaf_version          = '3.0.1'

  # Should user be managed?
  $karaf_manage_user      = true
  $karaf_user             = 'karaf'
  $karaf_group            = 'karaf'

  # Default Karaf install parent directory.
  $karaf_parent_dir       = '/opt'

  # Download location
  $karaf_download_site    = "http://mirror.catn.com/pub/apache/karaf/${karaf_version}"
  $karaf_download_file    = "apache-karaf-${karaf_version}.tar.gz"

  # Should a karaf service be created on installation?
  $karaf_create_service   = true
  # Default karaf service name
  $karaf_service_name     = undef

  # Should this module manage Java installation?
  $karaf_install_java     = true
  # Should this module manage Java env setup?
  $karaf_manage_java_home = true
  # JDK version: java-7-oracle, java-7-openjdk
  $karaf_java_ver         = 'java-7-openjdk'
  # Specify the JAVA_HOME value
  $karaf_java_home        = undef

  # Set package names based on Operating System...
  case $::osfamily {
    RedHat  : {
      $java7_openjdk_package = 'java-1.7.0-openjdk'
      $java7_openjdk_home    = '/usr/lib/jvm/jre'
      $java7_sun_package     = undef
      $java7_sun_home        = '/usr/java/default'
    }
    Debian  : {
      $java7_openjdk_package = 'openjdk-7-jdk'
      $java7_sun_package     = undef
    }
    default : {
      fail("${::osfamily} not supported")
    }
  }
}
