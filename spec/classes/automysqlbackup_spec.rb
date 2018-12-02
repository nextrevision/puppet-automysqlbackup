require 'spec_helper'

describe 'automysqlbackup' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "automysqlbackup class without any parameters on #{osfamily}" do
        let(:facts) { { 'osfamily' => osfamily } }

        # it { should include_class('automysqlbackup::params') }
        it 'installs the automysqlbackup binary' do
          is_expected.to contain_file('/usr/local/bin/automysqlbackup').with('ensure' => 'file',
                                                                             'owner'  => 'root',
                                                                             'group'  => 'root',
                                                                             'mode'   => '0755')
        end
        it 'makes the backup directory' do
          is_expected.to contain_file('/var/backup').with('ensure' => 'directory',
                                                          'owner' => 'root',
                                                          'group' => 'root',
                                                          'mode'  => '0755')
        end
        it 'creates the automysqlbackup config directory' do
          is_expected.to contain_file('/etc/automysqlbackup').with('ensure' => 'directory',
                                                                   'owner'  => 'root',
                                                                   'group'  => 'root',
                                                                   'mode'   => '0750')
        end
        it 'creates a sample config file' do
          is_expected.to contain_file('/etc/automysqlbackup/automysqlbackup.conf.example').with('ensure' => 'file',
                                                                                                'owner'  => 'root',
                                                                                                'group'  => 'root',
                                                                                                'mode'   => '0660')
        end
      end
      describe "automysqlbackup class with custom backup and etc dirs on #{osfamily}" do
        let(:params) do
          {
            'backup_dir' => '/data/backups',
            'etc_dir' => '/usr/local/etc/amb',
          }
        end
        let(:facts) { { 'osfamily' => osfamily } }

        it 'creates the custom backup directory' do
          is_expected.to contain_file('/data/backups').with('ensure' => 'directory',
                                                            'owner' => 'root',
                                                            'group' => 'root',
                                                            'mode'  => '0755')
        end
        it 'creates the custom etc directory' do
          is_expected.to contain_file('/usr/local/etc/amb').with('ensure' => 'directory',
                                                                 'owner' => 'root',
                                                                 'group' => 'root',
                                                                 'mode'  => '0750')
        end
        it 'creates automysqlbackup.conf.example in the custom etc directory' do
          is_expected.to contain_file('/usr/local/etc/amb/automysqlbackup.conf.example').with('ensure' => 'file',
                                                                                              'owner' => 'root',
                                                                                              'group' => 'root')
        end
      end
      describe "automysqlbackup class with install_multicore #{osfamily}" do
        let(:params) { { 'install_multicore' => true } }
        let(:facts) { { 'osfamily' => osfamily } }

        it 'installs multicore packages' do
          is_expected.to contain_package('pigz').with('ensure' => 'installed')
          is_expected.to contain_package('pbzip2').with('ensure' => 'installed')
        end
      end
      describe 'automysqlbackup class with invalid path' do
        let(:params) { { 'etc_dir' => 'not/absolute/path' } }
        let(:facts) { { 'osfamily' => osfamily } }

        it 'throws an error' do
          expect { is_expected.to contain_file('/etc/automysqlbackup') }.to raise_error(Puppet::Error, %r{not an absolute path})
        end
      end
    end
  end
end
