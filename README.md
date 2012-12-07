# Puppet module: automysqlbackup - README

## Intro

Before using this module, you need to consult the automysqlbackup developer documentation in order to comprehend what each option performs. It is included within this module and is certainly worth getting familiar with.

## Variable Names

I have kept the same variable names as the author of the script to make it easier to lookup the documentation. Essentially, add CONFIG_ to the variable in question and regex search the documentation to find the meaning. No interpretation from me.

## Supercedence

automysqlbackup.conf overwrites script values

Anything with an empty string implies that you are conceding to the default value in automysqlbackup.conf. Anything not specified in automysqlbackup.conf accepts the scripts builtin, default value of the script.

# Usage (finally)

Basic:

	class { 'automysqlbackup':
		mysql_dump_username	=> "root",
		mysql_dump_password => "password",
	}