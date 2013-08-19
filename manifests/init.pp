# == Class: automysqlbackup
#
# Puppet module to install and configure AutoMySQLBackup for periodic
# MySQL backups.
#
# Before using this module, you need to consult the automysqlbackup
# developer documentation in order to comprehend what each option
# performs. It is included within this module and is certainly
# worth getting familiar with.
#
# === Variables
#
# With the exception of $cron_script, I have kept the same variable
# names as the author of the script to make it easier to lookup the
# documentation. Essentially, add CONFIG_ to the variable in question
# and regex search the documentation to find the meaning. No interpretation
# from me.
#
# $install_multicore if set to true will install pigz and pbzip2 for 
# multicore compression. Assumes packages are available. 
#
# === Examples
#
#  class { 'automysqlbackup':
#    mysql_dump_username => "root",
#    mysql_dump_password => "password",
#  }
#
# === Authors
#
# NextRevision <notarobot@nextrevision.net>
#
# === Copyright
#
# Copyright 2012 NextRevision, unless otherwise noted.


class automysqlbackup (
  $bin_dir = $automysqlbackup::params::bin_dir,
  $etc_dir = $automysqlbackup::params::etc_dir,
  $backup_dir = $automysqlbackup::params::backup_dir,
  $install_multicore = undef,
  $config = {},
  $config_defaults = {}
) inherits automysqlbackup::params {

  file { $automysqlbackup::params::etc_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
  }

  file { "${automysqlbackup::params::etc_dir}/automysqlbackup.conf.example":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    source  => 'puppet:///modules/automysqlbackup/automysqlbackup.conf',
  }

  file { "${automysqlbackup::params::etc_dir}/AMB_README":
    ensure  => file,
    source  => 'puppet:///modules/automysqlbackup/AMB_README',
  }

  file { "${automysqlbackup::params::etc_dir}/AMB_LICENSE":
    ensure  => file,
    source  => 'puppet:///modules/automysqlbackup/AMB_LICENSE',
  }

  file { "${automysqlbackup::params::bin_dir}/automysqlbackup":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/automysqlbackup/automysqlbackup',
  }

  file { $backup_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  # if you'd like to keep your config in hiera and pass it to this class.
  if ! empty($config) {
    create_resources('automysqlbackup::backup',$config,$config_defaults)
  }
  
  if $install_multicore { 
    package { ['pigz', 'pbzip2']:
      ensure => installed
    }
  }

}
