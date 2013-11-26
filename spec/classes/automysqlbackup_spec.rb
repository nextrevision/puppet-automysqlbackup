require 'spec_helper'

describe 'automysqlbackup' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "automysqlbackup class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{ :osfamily => osfamily }}
        it { should include_class('automysqlbackup::params') }
        it 'should install the automysqlbackup binary' do
          should contain_file('/usr/local/bin/automysqlbackup').with({
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          })
        end
        it 'should make the backup directory' do 
          should contain_file('/var/backup').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0755',
          })
        end
        it 'should create the automysqlbackup config directory' do
          should contain_file('/etc/automysqlbackup').with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0750',
          })
        end
        it 'should create a sample config file' do
          should contain_file('/etc/automysqlbackup/automysqlbackup.conf.example').with({
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0660',
          })
        end
      end
      describe "automysqlbackup class with custom backup and etc dirs on #{osfamily}" do
        let(:params) {{
          :backup_dir => '/data/backups',
          :etc_dir    => '/usr/local/etc/amb',
        }}
        let(:facts) {{ :osfamily => osfamily }}
        it 'should create the custom backup directory' do 
          should contain_file('/data/backups').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0755',
          })
        end
        it 'should create the custom etc directory' do 
          should contain_file('/usr/local/etc/amb').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0750',
          })
        end
        it 'should create the custom etc directory' do 
          should contain_file('/usr/local/etc/amb/automysqlbackup.conf.example').with({
            'ensure' => 'file',
            'owner' => 'root',
            'group' => 'root',
          })
        end
      end
      describe "automysqlbackup class with install_multicore #{osfamily}" do
        let(:params) {{ :install_multicore => true }}
        let(:facts) {{ :osfamily => osfamily }}
        it 'should install multicore packages' do
          should contain_package('pigz').with({ 'ensure' => 'installed' })
          should contain_package('pbzip2').with({ 'ensure' => 'installed' })
        end
      end
      describe "automysqlbackup class with invalid path" do
        let(:params) {{ :etc_dir => "not/absolute/path" }}
        let(:facts) {{ :osfamily => osfamily }}
        it 'should throw an error' do
          expect { should }.to raise_error(Puppet::Error, /not an absolute path/)
        end
      end
    end
  end
end
