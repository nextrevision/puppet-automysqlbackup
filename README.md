# AutoMySQLBackup Module for Puppet

## Upgrade Notice

This module has been refactored. See the "Compatibility" section below if you
are updating from a previous version.

## Intro

Before using this module, it is highly recommended that you consult the
automysqlbackup developer documentation in order to comprehend what each option
performs. It is included within this module and is certainly worth getting
familiar with.

Documentation can be found here:
http://sourceforge.net/projects/automysqlbackup

## Compatibility

This module has been updated. Calling the 'automysqlbackup' class directly is
no longer supported. See the changelog and usage below for more information.

The module has sucessfully been tested on Ubuntu 12.04+, Debian 6.0, and
CentOS 6.4. If you find it doesn't work on your platform, open up a ticket on
the GitHub project page.

## Variable Names

I have kept the same variable names as the author of the script to make it
easier to lookup the documentation. Essentially, add CONFIG_ to the variable in
question and regex search the documentation to find the meaning. No
interpretation from me.

The exception to this rule are the "cron" variables which are local to the
puppet module. They, as the variable names imply, install a script to be run by
cron nightly in /etc/cron.daily/.

## Supercedence

automysqlbackup.conf overwrites script values

Anything with an empty string implies that you are conceding to the default
value in automysqlbackup.conf. Anything not specified in automysqlbackup.conf
accepts the scripts builtin, default value of the script.

## Usage

Usage comes in two ways. You can use the following in your manifests, or you
can load the backup configurating into automysqlbackup::config and
automysqlbackup::config_defaults via hiera or other ENC. 

### Basic:

    include automysql::backup
    automysqlbackup::backup { 'automysqlbackup':
      mysql_dump_username  => 'root',
      mysql_dump_password  => 'password',
    }

### Daily backups only excluding certain databases and tables:

    include automysql::backup
    automysqlbackup::backup { 'automysqlbackup':
      cron_template       => 'myrole/amb.cron.erb',
      mysql_dump_username => 'root',
      mysql_dump_password => 'password',
      do_monthly          => '0',
      do_weekly           => '0',
      db_exclude          => ['performance_schema','information_schema'],
      table_exclude       => ['mysql.event'],
    }

### Without cron job creation, changes the default backup directory:
    
    class { 'automysqlbackup':
      backup_dir           => '/mnt/backups'
    }

    automysqlbackup::backup { 'automysqlbackup':
      mysql_dump_username  => 'root',
      mysql_dump_password  => 'password',
      cron_script          => false,
    }

## Running the script manually

After installation, you may wish to periodically run the script manually. This
is possible by calling '/usr/local/bin/automysqlbackup config_file.conf'.
The default config file is 'automysqlbackup.conf', and unless you specify
'automysqlbackup' when defining the backup instance
(i.e. automysqlbackup::backup {'automysqlbackup': }), then you will need to
correctly specify the name of the configuration file to use.

## Support/Contribute

First, please read the developer's documentation for the automysqlbackup
script. If there is an issue with the Puppet module, or you have an addition to
make, please create a new issue or (even better) fork and change it, then
provide me with either a patch or a pull request and I'll be happy to add it
back in. If you have a feature you would like to see added, please create a new
issue and I'll see if I can't add it in shortly.
