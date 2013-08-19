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


define automysqlbackup::backup (
  $cron_script = true,
  $cron_set_permissions = true,
  $mysql_dump_username = '',
  $mysql_dump_password = '',
  $mysql_dump_host = '',
  $mysql_dump_port = 3306,
  $backup_dir = '',
  $backup_dir_owner = 'root',
  $backup_dir_group = 'root',
  $backup_dir_perms = '0700',
  $backup_file_perms = '0400',
  $etc_dir = '',
  $multicore = '',
  $multicore_threads = '',
  $db_names = [],
  $db_month_names = [],
  $db_exclude = [],
  $table_exclude = [],
  $do_monthly = '01',
  $do_weekly = '5',
  $rotation_daily = '6',
  $rotation_weekly = '35',
  $rotation_monthly = '150',
  $mysql_dump_commcomp = '',
  $mysql_dump_usessl = '',
  $mysql_dump_socket = '',
  $mysql_dump_max_allowed_packet = '',
  $mysql_dump_buffer_size = '',
  $mysql_dump_single_transaction = '',
  $mysql_dump_master_data = '',
  $mysql_dump_full_schema = '',
  $mysql_dump_dbstatus = '',
  $mysql_dump_create_database = '',
  $mysql_dump_use_separate_dirs = '',
  $mysql_dump_compression = 'gzip',
  $mysql_dump_latest = '',
  $mysql_dump_latest_clean_filenames = '',
  $mysql_dump_differential = '',
  $mailcontent = '',
  $mail_maxattsize = '',
  $mail_splitandtar = '',
  $mail_use_uuencoded_attachments = '',
  $mail_address = '',
  $encrypt = '',
  $encrypt_password = '',
  $backup_local_files = [],
  $prebackup = '',
  $postbackup = '',
  $umask = '',
  $dryrun = ''
) {
  
  include automysqlbackup

  if empty($backup_dir) {  
    $local_backup_dir = "${automysqlbackup::backup_dir}/${name}"
  } else {
    $local_backup_dir = "${backup_dir}/${name}"
  }

  if empty($etc_dir) {
    $local_etc_file = "${automysqlbackup::etc_dir}/${name}.conf"
  } else {
    $local_etc_file = "${etc_dir}/${name}.conf"
  }
 
  file { $local_backup_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
  if $cron_script {
    file { "/etc/cron.daily/${name}.automysqlbackup":
      ensure   => file,
      owner    => 'root',
      group    => 'root',
      mode     => '0755',
      content  => template('automysqlbackup/automysqlbackup.cron.erb'),
    }
  }

  # Creating a hash, really could probably avoid doing this, but wanted to try
  $template_string_options = {
    'mysql_dump_username' => $mysql_dump_username,
    'mysql_dump_password' => $mysql_dump_password,
    'mysql_dump_host' => $mysql_dump_host,
    'mysql_dump_port' => $mysql_dump_port,
    'backup_dir' => $local_backup_dir,
    'multicore' => $multicore,
    'multicore_threads' => $multicore_threads,
    'do_monthly' => $do_monthly,
    'do_weekly' => $do_weekly,
    'rotation_daily' => $rotation_daily,
    'rotation_weekly' => $rotation_weekly,
    'rotation_monthly' => $rotation_monthly,
    'mysql_dump_commcomp' => $mysql_dump_commcomp,
    'mysql_dump_usessl' => $mysql_dump_usessl,
    'mysql_dump_socket' => $mysql_dump_socket,
    'mysql_dump_max_allowed_packet' => $mysql_dump_max_allowed_packet,
    'mysql_dump_buffer_size' => $mysql_dump_buffer_size,
    'mysql_dump_single_transaction' => $mysql_dump_single_transaction,
    'mysql_dump_master_data' => $mysql_dump_master_data,
    'mysql_dump_full_schema' => $mysql_dump_full_schema,
    'mysql_dump_dbstatus' => $mysql_dump_dbstatus,
    'mysql_dump_create_database' => $mysql_dump_create_database,
    'mysql_dump_use_separate_dirs' => $mysql_dump_use_separate_dirs,
    'mysql_dump_compression' => $mysql_dump_compression,
    'mysql_dump_latest' => $mysql_dump_latest,
    'mysql_dump_latest_clean_filenames' => $mysql_dump_latest_clean_filenames,
    'mysql_dump_differential' => $mysql_dump_differential,
    'mailcontent' => $mailcontent,
    'mail_maxattsize' => $mail_maxattsize,
    'mail_splitandtar' => $mail_splitandtar,
    'mail_use_uuencoded_attachments' => $mail_use_uuencoded_attachments,
    'mail_address' => $mail_address,
    'encrypt' => $encrypt,
    'encrypt_password' => $encrypt_password,
    'prebackup' => $prebackup,
    'postbackup' => $postbackup,
    'umask' => $umask,
    'dryrun' => $dryrun
  }

  $template_array_options = {
    'db_names' => $db_names,
    'db_month_names' => $db_month_names,
    'db_exclude' => $db_exclude,
    'table_exclude' => $table_exclude,
    'backup_local_files' => $backup_local_files,
  }

  # last but not least, create the automysqlbackup.conf
  file { $local_etc_file:
    ensure  => file,
    content => template('automysqlbackup/automysqlbackup.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0650',
  }
}
