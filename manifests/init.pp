# == Class: karaf
#
# Full description of class karaf here.
#
# === Parameters
#
# [*sample_parameter*]
# Explanation of what this parameter affects and what it defaults to.
#
# === Examples
#
# `include karaf`
#
# === Authors
#
# Gavin Williams <fatmcgav@gmail.com>
#
# === Copyright
#
# Copyright 2014 Gavin Williams, unless otherwise noted.
#
class karaf (
  $create_service   = $karaf::params::karaf_create_service,
  $download_file    = $karaf::params::karaf_download_file,
  $download_site    = $karaf::params::karaf_download_site,
  $group            = $karaf::params::karaf_group,
  $install_dir      = $karaf::params::karaf_install_dir,
  $install_java     = $karaf::params::karaf_install_java,
  $install_method   = $karaf::params::karaf_install_method,
  $java_home        = $karaf::params::karaf_java_home,
  $java_ver         = $karaf::params::karaf_java_ver,
  $manage_java_home = $karaf::params::karaf_manage_java_home,
  $manage_path      = $karaf::params::karaf_manage_path,
  $manage_user      = $karaf::params::karaf_manage_user,
  $parent_dir       = $karaf::params::karaf_parent_dir,
  $start_on_install = $karaf::params::karaf_start_on_install,
  $tmp_dir          = $karaf::params::karaf_tmp_dir,
  $user             = $karaf::params::karaf_user,
  $version          = $karaf::params::karaf_version) inherits karaf::params {
  # validate parameters here
  validate_bool($create_service)
  validate_bool($install_java)
  validate_bool($manage_java_home)
  validate_bool($manage_path)
  validate_bool($manage_user)
  validate_bool($start_on_install)

  # Installation location
  if ($install_dir == undef) {
    $karaf_dir = "${parent_dir}/apache-karaf-${version}"
  } else {
    $karaf_dir = "${parent_dir}/${install_dir}"
  }

  # Need to manage path?
  if $manage_path {
    class { 'karaf::path': require => Class['karaf::install'] }
  }

  # Create a service?
  if $create_service {
    class { 'karaf::service':
      require => Class['karaf::path']
    }
  }

  anchor { 'karaf::begin': } ->
  class { 'karaf::java': } ->
  class { 'karaf::install': } ->
  class { 'karaf::config': } ->
  # class { 'karaf::service': } ->
  anchor { 'karaf::end': }
}
