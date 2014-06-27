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
  $add_path       = $karaf::params::karaf_add_path,
  #$create_service = $karaf::params::karaf_create_service,
  $download_file  = $karaf::params::karaf_download_file,
  $download_site  = $karaf::params::karaf_download_site,
  $group          = $karaf::params::karaf_group,
  $install_dir    = $karaf::params::karaf_install_dir,
  $install_method = $karaf::params::karaf_install_method,
  $manage_user    = $karaf::params::karaf_manage_user,
  $parent_dir     = $karaf::params::karaf_parent_dir,
  $tmp_dir        = $karaf::params::karaf_tmp_dir,
  $user           = $karaf::params::karaf_user,
  $version        = $karaf::params::karaf_version) inherits karaf::params {
  # validate parameters here

  # Installation location
  if ($install_dir == undef) {
    $karaf_dir = "${parent_dir}/apache-karaf-${version}"
  } else {
    $karaf_dir = "${parent_dir}/${install_dir}"
  }

  # Need to manage path?
  if $add_path {
    class { 'karaf::path': require => Class['karaf::install'] }
  }

  # Create a service?
  #if ($create_service) {
  #  class { 'karaf::service': require => Class['karaf::install'] }
  #}

  anchor { 'karaf::begin': } ->
  class { 'karaf::install': } ->
  # class { 'karaf::config': } ~>
  # class { 'karaf::service': } ->
  # Class['karaf']
  anchor { 'karaf::end': }
}
