# == Class karaf::java
#
# This class is meant to be called from karaf
# It installs and manages java
#
class karaf::java {
  # Get the package name based on required java_ver.
  case $karaf::java_ver {
    'java-7-oracle'  : {
      # require ::java7
      $java_package = $karaf::params::java7_sun_package
      $java_home    = $karaf::params::java7_sun_home
    }
    'java-7-openjdk' : {
      $java_package = $karaf::params::java7_openjdk_package
      $java_home    = $karaf::params::java7_openjdk_home
    }
    default          : {
      fail("Unrecognized Java version ${karaf::java_ver}. Choose one of: java-7-oracle, java-7-openjdk, java-6-oracle, java-6-openjdk"
      )
    }
  }

  # Handle JAVA_HOME
  if $karaf::java_home {
    $real_java_home = $karaf::java_home
  } else {
    $real_java_home = $java_home
  }

  # Install the required package, if set.
  if $karaf::install_java and $java_package {
    package { $java_package: ensure => 'installed' }
  }

  # Setup env if appropriate
  if $karaf::manage_java_home {
    case $::osfamily {
      'RedHat' : { $java_profile_template = template('karaf/profile.d/java-profile-el.erb') }
      'Debian' : { $java_profile_template = template('karaf/profile.d/java-profile-deb.erb') }
      default  : { fail("OSFamily ${::osfamily} is not currently supported.") }
    }

    # Add a file to the profile.d directory
    file { '/etc/profile.d/java.sh':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $java_profile_template,
      require => Package[$java_package]
    }

  }

}
