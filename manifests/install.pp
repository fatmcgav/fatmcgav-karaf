# == Class karaf::install
#
# This class is meant to be called from karaf
# It installs karaf
#
class karaf::install {
  # Anchor the install class
  anchor { 'karaf::install::begin': }

  anchor { 'karaf::install::end': }

  # Create user/group if required
  if $karaf::manage_user {
    # Create the required group.
    group { $karaf::group:
      ensure  => 'present',
      require => Anchor['karaf::install::begin']
    }

    # Create the required user.
    user { $karaf::user:
      ensure     => 'present',
      managehome => true,
      comment    => 'Karaf user account',
      gid        => $karaf::group,
      require    => Group[$karaf::group]
    }
  }

  # Take action based on $install_method.
  case $karaf::install_method {
    'package' : {
      # Build package from $package_prefix and $version
      $package_name = "apache-karaf-${karaf::version}"

      # Install the package.
      package { $package_name:
        ensure  => present,
        require => Anchor['karaf::install::begin'],
        before  => Anchor['karaf::install::end']
      }

      # Run User/Group create before Package install, If manage_accounts = true.
      if $karaf::manage_user {
        User[$karaf::user] -> Package[$package_name]
      }
    }
    'zip'     : {
      # Need to download karaf from karaf.apache.org
      $karaf_download_site = $karaf::download_site
      $karaf_download_file = $karaf::download_file
      $karaf_download_dest = "${karaf::tmp_dir}/${karaf_download_file}"

      # Set default path
      Exec {
        path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

      # Make sure that $tmp_dir exists.
      file { $karaf::tmp_dir:
        ensure  => directory,
        require => Anchor['karaf::install::begin'],
      }

      # Download file
      exec { "download_${karaf_download_file}":
        command => "wget -q ${karaf_download_site}/${karaf_download_file} -O ${karaf_download_dest}",
        creates => $karaf_download_dest,
        timeout => '300',
        require => File[$karaf::tmp_dir]
      }

      # Unzip the downloaded karaf zip filek
      exec { 'extract-karaf':
        command => "tar zxf ${karaf_download_dest}",
        cwd     => $karaf::tmp_dir,
        creates => $karaf::karaf_dir,
        require => Exec["download_${karaf_download_file}"]
      }

      # Chown karaf folder.
      exec { 'change-ownership':
        command => "chown -R ${karaf::user}:${karaf::group} ${karaf::tmp_dir}/apache-karaf-${karaf::version}",
        creates => $karaf::karaf_dir,
        require => Exec['extract-karaf']
      }

      # Make sure that user creation runs before ownership change, IF
      # manage_user = true.
      if $karaf::manage_user {
        User[$karaf::user] -> Exec['change-ownership']
      }

      # Move the apache-karaf folder.
      exec { "move-karaf-${karaf::version}":
        command => "mv ${karaf::tmp_dir}/apache-karaf-${karaf::version} ${karaf::karaf_dir}",
        cwd     => $karaf::tmp_dir,
        creates => $karaf::karaf_dir,
        require => Exec['change-ownership'],
        before  => Anchor['karaf::install::end']
      }

      # Start karaf on installation?
      if $karaf::start_on_install {
        exec { "start-karaf-${karaf::version}":
          command => "sh -c \"${karaf::karaf_dir}/bin/start\"",
          #user    => $karaf::user,
          cwd     => $karaf::karaf_dir,
          unless  => 'ps -ef |grep org.apache.karaf|grep -v grep',
          require => Exec["move-karaf-${karaf::version}"],
          before  => Anchor['karaf::install::end']
        }
      }
    }
    default   : {
      fail("Unrecognised Installation method ${karaf::install_method}. Choose one of: 'package','zip'.")
    }
  }

}
