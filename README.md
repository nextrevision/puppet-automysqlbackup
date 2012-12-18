# AutoMySQLBackup Module for Puppet

## Intro

Before using this module, it is highly recommended that you consult the automysqlbackup developer documentation in order to comprehend what each option performs. It is included within this module and is certainly worth getting familiar with.

Documentation can be found here: http://sourceforge.net/projects/automysqlbackup

## Compatibility

The module has sucessfully been tested on Ubuntu 12.04+, Debian 6.0, and CentOS 6.3. If you find it doesn't work on your platform, open up a ticket on the GitHub project page.

## Variable Names

I have kept the same variable names as the author of the script to make it easier to lookup the documentation. Essentially, add CONFIG_ to the variable in question and regex search the documentation to find the meaning. No interpretation from me.

The exception to this rule is the "cron_script" variable which is local to the puppet module. It, as the variable name implies, installs a script to be run by cron nightly in /etc/cron.daily/.

## Supercedence

automysqlbackup.conf overwrites script values

Anything with an empty string implies that you are conceding to the default value in automysqlbackup.conf. Anything not specified in automysqlbackup.conf accepts the scripts builtin, default value of the script.

## Usage

### Basic:

	class { 'automysqlbackup':
		mysql_dump_username	=> "root",
		mysql_dump_password	=> "password",
	}

### Daily backups only excluding certain databases:
	
	class { "automysqlbackup": 
		mysql_dump_username	=> "root",
		mysql_dump_password => "password",
		do_monthly			=> "0",
		do_weekly			=> "0",
		db_exclude			=> ['performance_schema','information_schema'],
	}

### Without cron job creation:
	class { 'automysqlbackup':
		mysql_dump_username	=> "root",
		mysql_dump_password => "password",
		cron_script			=> false,
	}

## Support/Contribute

First, please read the developer's documentation for the automysqlbackup script. If there is an issue with the Puppet module, or you have an addition to make, please create a new issue or (even better) fork and change it, then provide me with either a patch or a pull request and I'll be happy to add it back in. If you have a feature you would like to see added, please create a new issue and I'll see if I can't add it in shortly.