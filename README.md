# AutoMySQLBackup Module for Puppet

[![Build Status](https://travis-ci.org/nextrevision/puppet-automysqlbackup.png?branch=master)](https://travis-ci.org/nextrevision/puppet-automysqlbackup)

####Table of Contents

1. [Upgrade Notice](#upgrade-notice)
2. [Intro](#intro)
3. [Compatibility](#compatibility)
4. [Variable Names](#variable-names)
5. [Supercedence](#supercedence)
5. [Usage](#usage)
6. [Running the script manually](#running-the-script-manually)
7. [Support/Contribute](#support-contribute)
8. [Contributors](#contributors)

## Upgrade Notice

If upgrading from 0.1.X to 0.2.X, please see the compatibility section below.

0.2.3 fixed a naming issue in the cron script. To avoid duplicate cron jobs,
it will remove and $name.automysqlbackup in favor of $name-automysqlbackup in
/etc/cron.daily/.

There was also an issue in 0.2.1 (previous release) with installing from Forge.
This was fixed as of 0.2.2 and the manifests have been correctly populated.

## Intro

Before using this module, it is highly recommended that you consult the
automysqlbackup developer documentation in order to comprehend what each option
performs. It is included within this module and is certainly worth getting
familiar with.

Documentation can be found here:
http://sourceforge.net/projects/automysqlbackup

## Compatibility

Ever since 0.2.X, this module has been updated. Calling the 'automysqlbackup'
class directly is no longer supported. See the changelog and usage below for
more information.

The module has sucessfully been tested on Ubuntu (10.04 and 12.04), Debian (6
and 7), and CentOS (5.9 and 6.4). If you find it doesn't work on your platform,
open up a ticket on the GitHub project page.

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

## Contributors

* nextrevision
* zsprackett
* rhysrhaven
* rjw1

