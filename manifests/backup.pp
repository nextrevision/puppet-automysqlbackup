# == Class: automysqlbackup::backup
#
# Puppet manifest used to configure AutoMySQLBackup for periodic MySQL
# backups.
#
# Before using this module, you need to consult the automysqlbackup
# developer documentation in order to comprehend what each option
# performs. It is included within this module and is certainly
# worth getting familiar with.
#
# === Variables
#
# With the exception of the cron and file permision variables, I have
# kept the same variable names as the author of the script to make it easier to
# lookup the documentation. Essentially, add CONFIG_ to the variable in question
# and regex search the documentation to find the meaning. No interpretation
# from me.
#
# If $backup_dir is not specified, it will default to that listed in init.pp.
#
# === Examples
#
#  automysqlbackup::backup { 'automysqlbackup':
#    mysql_dump_username => 'root',
#    mysql_dump_password => 'password',
#  }
#
#  ...or something slightly more involved:
#
#  automysqlbackup::backup { 'automysqlbackup':
#    cron_script         => false,
#    cron_template       => 'myrole/amb.cron.erb',
#    mysql_dump_username => 'root',
#    mysql_dump_password => 'password',
#    do_monthly          => '0',
#    do_weekly           => '0',
#    db_exclude          => ['performance_schema', 'information_schema'],
#    table_exclude       => ['mysql.event'],
#  }
#
# === Authors
#
# NextRevision <notarobot@nextrevision.net>
#
# === Copyright
#
# Copyright 2013 NextRevision, unless otherwise noted.


define automysqlbackup::backup (
  # General settings
  Boolean                                         $cron_script                        = true,
  String[1]                                       $cron_template                      = 'automysqlbackup/automysqlbackup.cron.erb',
  Boolean                                         $cron_set_permissions               = true,
  Optional[Stdlib::Absolutepath]                  $etc_dir                            = undef,
  String[1]                                       $backup_dir_owner                   = 'root',
  String[1]                                       $backup_dir_group                   = 'root',
  Stdlib::Filemode                                $backup_dir_perms                   = '0700',
  Stdlib::Filemode                                $backup_file_perms                  = '0400',
  # Automysqlbackup specific config settings
  Optional[Stdlib::Absolutepath]                  $backup_dir                         = undef,
  String[1]                                       $mysql_dump_username                = 'root',
  String                                          $mysql_dump_password                = '',
  Stdlib::Host                                    $mysql_dump_host                    = 'localhost',
  Stdlib::Port                                    $mysql_dump_port                    = 3306,
  Enum['yes', 'no']                               $multicore                          = 'no',
  Integer[1]                                      $multicore_threads                  = 2,
  Array[String[1]]                                $db_names                           = [],
  Array[String[1]]                                $db_month_names                     = [],
  Array[String[1]]                                $db_exclude                         = [],
  Array[String[1]]                                $table_exclude                      = [],
  Automysqlbackup::Do_monthly                     $do_monthly                         = '01',
  Integer[1,7]                                    $do_weekly                          = 5,
  Integer[1]                                      $rotation_daily                     = 6,
  Integer[1]                                      $rotation_weekly                    = 35,
  Integer[1]                                      $rotation_monthly                   = 150,
  Enum['yes', 'no']                               $mysql_dump_commcomp                = 'no',
  Enum['yes', 'no']                               $mysql_dump_usessl                  = 'yes',
  Variant[String[0,0], Stdlib::Absolutepath]      $mysql_dump_socket                  = '',
  Variant[String[0,0], Integer[1024, 1073741824]] $mysql_dump_max_allowed_packet      = '',
  $mysql_dump_buffer_size             = '', #??????
  Enum['yes', 'no']                               $mysql_dump_single_transaction      = 'no',
  Variant[String[0,0], Integer[1,2]]              $mysql_dump_master_data             = '',
  Enum['yes', 'no']                               $mysql_dump_full_schema             = 'yes',
  Enum['yes', 'no']                               $mysql_dump_dbstatus                = 'yes',
  Enum['yes', 'no']                               $mysql_dump_create_database         = 'no',
  Enum['yes', 'no']                               $mysql_dump_use_separate_dirs       = 'yes',
  String[1]                                       $mysql_dump_compression             = 'gzip',
  Enum['yes', 'no']                               $mysql_dump_latest                  = 'no',
  Enum['yes', 'no']                               $mysql_dump_latest_clean_filenames  = 'no',
  Enum['yes', 'no']                               $mysql_dump_differential            = 'no',
  String[1]                                       $mailcontent                        = 'stdout',
  Integer[1]                                      $mail_maxattsize                    = 4000,
  Enum['yes', 'no']                               $mail_splitandtar                   = 'yes',
  Enum['yes', 'no']                               $mail_use_uuencoded_attachments     = 'no',
  String[1]                                       $mail_address                       = 'root',
  Enum['yes', 'no']                               $encrypt                            = 'no',
  String                                          $encrypt_password                   = 'password0123',
  Array[String[1]]                                $backup_local_files                 = [],
  String                                          $prebackup                          = '',
  String                                          $postbackup                         = '',
  Variant[[String[0,0], Stdlib::Filemode]]        $umask                              = '',
  String                                          $dryrun                             = '',
) {
  include automysqlbackup

  if $backup_dir {
    $backup_dir_real = "${backup_dir}/${name}"
  } else {
    $backup_dir_real = "${automysqlbackup::backup_dir}/${name}"
  }

  if $etc_dir {
    $etc_file_real = "${etc_dir}/${name}.conf"
  } else {
    $etc_file_real = "${automysqlbackup::etc_dir}/${name}.conf"
  }

  # Create the backup directory for the backup instance
  file { $backup_dir_real:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  if $cron_script {
    file { "/etc/cron.daily/${name}-automysqlbackup":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template($cron_template),
    }
    # Older versions of the module had name.automysqlbackup so to prevent
    # duplicating the cron job, enforce no older versions are still lingering
    # around and use the proper syntax above
    file { "/etc/cron.daily/${name}.automysqlbackup":
      ensure  => absent,
    }
  }

  # Creating a hash for the template, really could probably avoid doing this
  $template_string_options = {
    'mysql_dump_username'               => $mysql_dump_username,
    'mysql_dump_password'               => $mysql_dump_password,
    'mysql_dump_host'                   => $mysql_dump_host,
    'mysql_dump_port'                   => $mysql_dump_port,
    'backup_dir'                        => $backup_dir_real,
    'multicore'                         => $multicore,
    'multicore_threads'                 => $multicore_threads,
    'do_monthly'                        => $do_monthly,
    'do_weekly'                         => $do_weekly,
    'rotation_daily'                    => $rotation_daily,
    'rotation_weekly'                   => $rotation_weekly,
    'rotation_monthly'                  => $rotation_monthly,
    'mysql_dump_commcomp'               => $mysql_dump_commcomp,
    'mysql_dump_usessl'                 => $mysql_dump_usessl,
    'mysql_dump_socket'                 => $mysql_dump_socket,
    'mysql_dump_max_allowed_packet'     => $mysql_dump_max_allowed_packet,
    'mysql_dump_buffer_size'            => $mysql_dump_buffer_size,
    'mysql_dump_single_transaction'     => $mysql_dump_single_transaction,
    'mysql_dump_master_data'            => $mysql_dump_master_data,
    'mysql_dump_full_schema'            => $mysql_dump_full_schema,
    'mysql_dump_dbstatus'               => $mysql_dump_dbstatus,
    'mysql_dump_create_database'        => $mysql_dump_create_database,
    'mysql_dump_use_separate_dirs'      => $mysql_dump_use_separate_dirs,
    'mysql_dump_compression'            => $mysql_dump_compression,
    'mysql_dump_latest'                 => $mysql_dump_latest,
    'mysql_dump_latest_clean_filenames' => $mysql_dump_latest_clean_filenames,
    'mysql_dump_differential'           => $mysql_dump_differential,
    'mailcontent'                       => $mailcontent,
    'mail_maxattsize'                   => $mail_maxattsize,
    'mail_splitandtar'                  => $mail_splitandtar,
    'mail_use_uuencoded_attachments'    => $mail_use_uuencoded_attachments,
    'mail_address'                      => $mail_address,
    'encrypt'                           => $encrypt,
    'encrypt_password'                  => $encrypt_password,
    'prebackup'                         => $prebackup,
    'postbackup'                        => $postbackup,
    'umask'                             => $umask,
    'dryrun'                            => $dryrun,
    'db_names'                          => $db_names,
    'db_month_names'                    => $db_month_names,
    'db_exclude'                        => $db_exclude,
    'table_exclude'                     => $table_exclude,
    'backup_local_files'                => $backup_local_files
  }

  # Last but not least, create the config file
  file { $etc_file_real:
    ensure  => file,
    content => template('automysqlbackup/automysqlbackup.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0650',
  }
}
