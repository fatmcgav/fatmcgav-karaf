# == Class karaf::service
#
# This class is meant to be called from karaf
# It creates and configures a karaf servicefile
#
class karaf::service {
  karaf_feature { 'wrapper': ensure => 'present' }

  exec { 'install-service':
    command => 'client -r 30 wrapper:install',
    user    => $karaf::user,
    path    => "${karaf::karaf_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    unless  => "test -f ${karaf::karaf_dir}/bin/karaf-service",
    require => Karaf_feature['wrapper']
  }

  file { 'link-service':
    ensure  => 'link',
    target  => "${karaf::karaf_dir}/bin/karaf-service",
    path    => '/etc/init.d/karaf-service',
    require => Exec['install-service']
  }

  if $karaf::start_on_install {
    exec { 'stop-karaf':
      command => "sh -c \"${karaf::karaf_dir}/bin/stop\"",
      user    => $karaf::user,
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      onlyif  => 'ps -ef |grep org.apache.karaf.main.Main|grep -v grep',
      require => File['link-service'],
      before  => Service['karaf-service']
    }
  }

  service { 'karaf-service':
    ensure  => 'running',
    enable  => true,
    require => File['link-service']
  }

}
