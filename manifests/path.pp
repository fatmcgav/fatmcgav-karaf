# == Class: karaf::path
#
# This class is meant to be called from karaf
# Add karaf to profile path
#
class karaf::path {
  case $::osfamily {
    'RedHat' : { $profile_template = template('karaf/karaf-profile-el.erb') }
    'Debian' : { $profile_template = template('karaf/karaf-profile-deb.erb') }
    default  : { fail("OSFamily ${::osfamily} is not currently supported.") }
  }

  # Add a file to the profile.d directory
  file { '/etc/profile.d/karaf.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $profile_template
  }

}
