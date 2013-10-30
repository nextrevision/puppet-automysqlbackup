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
# If $backup_dir is not specified, it will default to that listed in params.pp.
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
  $cron_script          = true,
  $cron_template        = 'automysqlbackup/automysqlbackup.cron.erb',
  $cron_set_permissions = true,
  $etc_dir              = '',
  $backup_dir_owner     = 'root',
  $backup_dir_group     = 'root',
  $backup_dir_perms     = '0700',
  $backup_file_perms    = '0400',
  # Automysqlbackup specific config settings
  $backup_dir           = '',
  $mysql_dump_username  = '',
  $mysql_dump_password  = '',
  $mysql_dump_host      = '',
  $mysql_dump_port      = 3306,
  $multicore            = '',
  $multicore_threads    = '',
  $db_names             = [],
  $db_month_names       = [],
  $db_exclude           = [],
  $table_exclude        = [],
  $do_monthly           = '01',
  $do_weekly            = '5',
  $rotation_daily       = '6',
  $rotation_weekly      = '35',
  $rotation_monthly     = '150',
  $mysql_dump_commcomp  = '',
  $mysql_dump_usessl    = '',
  $mysql_dump_socket    = '',
  $mysql_dump_max_allowed_packet     = '',
  $mysql_dump_buffer_size            = '',
  $mysql_dump_single_transaction     = '',
  $mysql_dump_master_data            = '',
  $mysql_dump_full_schema            = '',
  $mysql_dump_dbstatus  = '',
  $mysql_dump_create_database        = '',
  $mysql_dump_use_separate_dirs      = '',
  $mysql_dump_compression            = 'gzip',
  $mysql_dump_latest    = '',
  $mysql_dump_latest_clean_filenames = '',
  $mysql_dump_differential           = '',
  $mailcontent          = '',
  $mail_maxattsize      = '',
  $mail_splitandtar     = '',
  $mail_use_uuencoded_attachments    = '',
  $mail_address         = '',
  $encrypt              = '',
  $encrypt_password     = '',
  $backup_local_files   = [],
  $prebackup            = '',
  $postbackup           = '',
  $umask                = '',
  $dryrun               = ''
) {

  include automysqlbackup

  if empty($backup_dir) {
    $backup_dir_real = "${automysqlbackup::backup_dir}/${name}"
  } else {
    $backup_dir_real = "${backup_dir}/${name}"
  }

  if empty($etc_dir) {
    $etc_file_real = "${automysqlbackup::etc_dir}/${name}.conf"
  } else {
    $etc_file_real = "${etc_dir}/${name}.conf"
  }

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
  }

  # Creating a hash for the template, really could probably avoid doing this
  $template_string_options = {
    'mysql_dump_username'     => $mysql_dump_username,
    'mysql_dump_password'     => $mysql_dump_password,
    'mysql_dump_host'         => $mysql_dump_host,
    'mysql_dump_port'         => $mysql_dump_port,
    'backup_dir'              => $backup_dir_real,
    'multicore'               => $multicore,
    'multicore_threads'       => $multicore_threads,
    'do_monthly'              => $do_monthly,
    'do_weekly'               => $do_weekly,
    'rotation_daily'          => $rotation_daily,
    'rotation_weekly'         => $rotation_weekly,
    'rotation_monthly'        => $rotation_monthly,
    'mysql_dump_commcomp'     => $mysql_dump_commcomp,
    'mysql_dump_usessl'       => $mysql_dump_usessl,
    'mysql_dump_socket'       => $mysql_dump_socket,
    'mysql_dump_max_allowed_packet'     => $mysql_dump_max_allowed_packet,
    'mysql_dump_buffer_size'  => $mysql_dump_buffer_size,
    'mysql_dump_single_transaction'     => $mysql_dump_single_transaction,
    'mysql_dump_master_data'  => $mysql_dump_master_data,
    'mysql_dump_full_schema'  => $mysql_dump_full_schema,
    'mysql_dump_dbstatus'     => $mysql_dump_dbstatus,
    'mysql_dump_create_database'        => $mysql_dump_create_database,
    'mysql_dump_use_separate_dirs'      => $mysql_dump_use_separate_dirs,
    'mysql_dump_compression'  => $mysql_dump_compression,
    'mysql_dump_latest'       => $mysql_dump_latest,
    'mysql_dump_latest_clean_filenames' => $mysql_dump_latest_clean_filenames,
    'mysql_dump_differential' => $mysql_dump_differential,
    'mailcontent'             => $mailcontent,
    'mail_maxattsize'         => $mail_maxattsize,
    'mail_splitandtar'        => $mail_splitandtar,
    'mail_use_uuencoded_attachments'    => $mail_use_uuencoded_attachments,
    'mail_address'            => $mail_address,
    'encrypt'                 => $encrypt,
    'encrypt_password'        => $encrypt_password,
    'prebackup'               => $prebackup,
    'postbackup'              => $postbackup,
    'umask'                   => $umask,
    'dryrun'                  => $dryrun
  }

  $template_array_options = {
    'db_names'           => $db_names,
    'db_month_names'     => $db_month_names,
    'db_exclude'         => $db_exclude,
    'table_exclude'      => $table_exclude,
    'backup_local_files' => $backup_local_files,
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
