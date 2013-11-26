require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.tty = true
  c.include RSpecSystemPuppet::Helpers

  c.before :suite do
    puppet_install
    puppet_module_install(:source => proj_root, :module_name => 'automysqlbackup')
    shell('puppet module install puppetlabs/stdlib --version 3.0.0')
  end

  c.before(:all) do
    shell('echo Starting')
  end
  c.after(:all) do
    shell('echo Finishing')
  end

end
