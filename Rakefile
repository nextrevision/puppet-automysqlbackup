require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rspec-system/rake_task'
# blacksmith fails with 1.8.x
require 'puppet_blacksmith/rake_tasks' if RUBY_VERSION > '1.9'

PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]

task :centos59 do
  sh %{RS_SET='centos-59-x64' rake spec:system}
end

task :centos64 do
  sh %{RS_SET='centos-64-x64' rake spec:system}
end

task :ubuntu1204 do
  sh %{RS_SET='ubuntu-server-12042-x64' rake spec:system}
end

task :ubuntu1004 do
  sh %{RS_SET='ubuntu-server-10044-x64' rake spec:system}
end

task :debian6 do
  sh %{RS_SET='debian-607-x64' rake spec:system}
end

task :debian7 do
  sh %{RS_SET='debian-70rc1-x64' rake spec:system}
end

task :centos => [
  :centos59,
  :centos64,
]

task :ubuntu => [
  :ubuntu1004,
  :ubuntu1204,
]

task :debian => [
  :debian6,
  :debian7,
]

task :allsystems => [
  :centos,
  :ubuntu,
  :debian,
]
