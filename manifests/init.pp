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

  anchor { 'karaf::begin': } ->
  class { 'karaf::install': } ->
  # class { 'karaf::config': } ~>
  # class { 'karaf::service': } ->
  # Class['karaf']
  anchor { 'karaf::end':}
}
