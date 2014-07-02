# == Class karaf::config
#
# This class is meant to be called from karaf
# It configures java
#
class karaf::config {
  file { "${karaf::karaf_dir}/etc/karaf-wrapper.conf":
    owner   => $karaf::user,
    group   => $karaf::group,
    content => template('karaf/etc/karaf-wrapper.conf.erb'),
    notify  => Service['karaf-service']
  }

}
