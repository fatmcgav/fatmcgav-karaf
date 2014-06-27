# == Class karaf::service
#
# This class is meant to be called from karaf
# It creates and configures a karaf servicefile
#
class karaf::service  {
  
  exec { 'install_wrapper_feature':
    command => "${karaf::karaf_dir}/bin/client feature:install wrapper"
  }
  
}
