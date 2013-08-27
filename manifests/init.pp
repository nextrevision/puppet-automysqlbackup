# == Class: automysqlbackup
#
# Puppet module to install AutoMySQLBackup for periodic MySQL backups.
#
#
# === Variables
#
# If $install_multicore is set to true, it will install pigz and pbzip2 for
# multicore compression. Assumes packages are available.
#
# $config and $config_defaults can be used by Hiera to pass a hash of hashes to
# create instances via an ENC.
#
# === Examples
#
#  class { 'automysqlbackup': }
#
# === Authors
#
# NextRevision <notarobot@nextrevision.net>
#
# === Copyright
#
# Copyright 2013 NextRevision, unless otherwise noted.

class automysqlbackup (
  $bin_dir           = $automysqlbackup::params::bin_dir,
  $etc_dir           = $automysqlbackup::params::etc_dir,
  $backup_dir        = $automysqlbackup::params::backup_dir,
  $install_multicore = undef,
  $config            = {},
  $config_defaults   = {},
) inherits automysqlbackup::params {

  # Create a subdirectory in /etc for config files
  file { $automysqlbackup::params::etc_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  # Create an example backup file, useful for reference
  file { "${automysqlbackup::params::etc_dir}/automysqlbackup.conf.example":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0660',
    source => 'puppet:///modules/automysqlbackup/automysqlbackup.conf',
  }

  # Add files from the developer
  file { "${automysqlbackup::params::etc_dir}/AMB_README":
    ensure => file,
    source => 'puppet:///modules/automysqlbackup/AMB_README',
  }
  file { "${automysqlbackup::params::etc_dir}/AMB_LICENSE":
    ensure => file,
    source => 'puppet:///modules/automysqlbackup/AMB_LICENSE',
  }

  # Install the actual binary file
  file { "${automysqlbackup::params::bin_dir}/automysqlbackup":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/automysqlbackup/automysqlbackup',
  }

  # Create the base backup directory
  file { $backup_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # If you'd like to keep your config in hiera and pass it to this class
  if !empty($config) {
    create_resources('automysqlbackup::backup', $config, $config_defaults)
  }

  if $install_multicore {
    package { ['pigz', 'pbzip2']: ensure => installed }
  }

}
