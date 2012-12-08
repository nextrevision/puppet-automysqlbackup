# automysqlbackup Module for Puppet

## Intro

Before using this module, you need to consult the automysqlbackup developer documentation in order to comprehend what each option performs. It is included within this module and is certainly worth getting familiar with.

## Variable Names

I have kept the same variable names as the author of the script to make it easier to lookup the documentation. Essentially, add CONFIG_ to the variable in question and regex search the documentation to find the meaning. No interpretation from me.

## Supercedence

automysqlbackup.conf overwrites script values

Anything with an empty string implies that you are conceding to the default value in automysqlbackup.conf. Anything not specified in automysqlbackup.conf accepts the scripts builtin, default value of the script.

## Usage

### Basic:

	class { 'automysqlbackup':
		mysql_dump_username	=> "root",
		mysql_dump_password => "password",
	}

### Daily backups only excluding certain databases:
	
	class { "automysqlbackup": 
		mysql_dump_username	=> "root",
		mysql_dump_password => "password",
		do_monthly			=> "0",
		do_weekly			=> "0",
		db_exclude			=> ['performance_schema','information_schema'],
	}

## Support/Contribute

First, read the developer's documentation for the automysqlbackup script. If there is an issue with the Puppet module, or you have an addition to make, please create a new issue or (even better) fork and change it, then provide me with either a patch or a pull request and I'll be happy to add it back in.

## To Do

* Cron job addition