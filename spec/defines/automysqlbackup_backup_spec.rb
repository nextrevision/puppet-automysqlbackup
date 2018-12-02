require 'spec_helper'

describe 'automysqlbackup::backup' do
  let :default_params do
    {
      cron_script: false,
      backup_dir: '/backup',
      etc_dir: '/usr/local/etc',
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:title) { 'db1' }
      let(:facts) { facts }
      describe "with all params on defaults" do
        let(:params) { {} }
        let(:pre_condition) { 'include automysqlbackup' }

        it 'contains the automysqlbackup db config file' do
          is_expected.to contain_file('/etc/automysqlbackup/db1.conf').with('ensure' => 'file',
                                                                            'owner'  => 'root',
                                                                            'group'  => 'root',
                                                                            'mode'   => '0650')
        end
        it 'creates the cron job' do
          is_expected.to contain_file('/etc/cron.daily/db1-automysqlbackup').with('ensure' => 'file',
                                                                                  'owner'  => 'root',
                                                                                  'group'  => 'root',
                                                                                  'mode'   => '0755')
        end
        it 'creates the backup destination' do
          is_expected.to contain_file('/var/backup/db1').with('ensure' => 'directory',
                                                              'owner'  => 'root',
                                                              'group'  => 'root',
                                                              'mode'   => '0755')
        end
      end
      describe 'with dir params changed and cron disabled' do
        let(:params) { default_params }
        let(:pre_condition) { 'include automysqlbackup' }

        it 'contains the automysqlbackup db config file' do
          is_expected.to contain_file('/usr/local/etc/db1.conf').with('ensure' => 'file',
                                                                      'owner'  => 'root',
                                                                      'group'  => 'root',
                                                                      'mode'   => '0650')
        end
        it 'creates the backup destination' do
          is_expected.to contain_file('/backup/db1').with('ensure' => 'directory',
                                                          'owner'  => 'root',
                                                          'group'  => 'root',
                                                          'mode'   => '0755')
        end
        it 'does not create cron job' do
          is_expected.not_to contain_file('/etc/cron.daily/db1-automysqlbackup')
        end
      end
      describe 'with amb class using non-default etc dir' do
        let(:params) { {} }
        let(:pre_condition) { 'class { "automysqlbackup": etc_dir => "/usr/local/etc/amb", } ' }

        it 'creates the config file' do
          is_expected.to contain_file('/usr/local/etc/amb/db1.conf').with('ensure' => 'file',
                                                                          'owner'  => 'root',
                                                                          'group'  => 'root',
                                                                          'mode'   => '0650')
        end
      end
      describe 'with amb class using non-default backup dir' do
        let(:params) { {} }
        let(:pre_condition) { 'class { "automysqlbackup": backup_dir => "/amb-backups", } ' }

        it 'creates the config file' do
          is_expected.to contain_file('/amb-backups/db1').with('ensure' => 'directory',
                                                               'owner'  => 'root',
                                                               'group'  => 'root',
                                                               'mode'   => '0755')
        end
      end
      describe 'with string for array param' do
        let(:params) { { db_exclude: 'stringval' } }
        let(:pre_condition) { 'include automysqlbackup' }

        it 'throws an error' do
          expect { is_expected.to contain_file('/etc/automysqlbackup/db1.conf') }.to raise_error(Puppet::Error, %r{expects an Array value})
        end
      end
    end
  end

  describe 'config template items' do
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystemrelease: '6',
      }
    end
    let(:title) { 'db1' }
    let(:params) { default_params }

    # All match and notmatch should be a list of regexs and exact match strings
    context '.conf content' do
      [
        {
          title: 'should contain backup_dir',
          attr: 'backup_dir',
          value: '/var/backup',
          match: [%r{CONFIG_backup_dir='\/var\/backup\/db1'}],
        },
        {
          title: 'should contain mysql_dump_username',
          attr: 'mysql_dump_username',
          value: 'mysqlroot',
          match: [%r{CONFIG_mysql_dump_username='mysqlroot'}],
        },
        {
          title: 'should contain mysql_dump_password',
          attr: 'mysql_dump_password',
          value: 'mysqlpass',
          match: [%r{CONFIG_mysql_dump_password='mysqlpass'}],
        },
        {
          title: 'should contain mysql_dump_host',
          attr: 'mysql_dump_host',
          value: '192.168.1.1',
          match: [%r{CONFIG_mysql_dump_host='192.168.1.1'}],
        },
        {
          title: 'should contain mysql_dump_port',
          attr: 'mysql_dump_port',
          value: 2207,
          match: [%r{CONFIG_mysql_dump_port='2207'}],
        },
        {
          title: 'should contain multicore',
          attr: 'multicore',
          value: 'yes',
          match: [%r{CONFIG_multicore='yes'}],
        },
        {
          title: 'should contain multicore_threads',
          attr: 'multicore_threads',
          value: 3,
          match: [%r{CONFIG_multicore_threads='3'}],
        },
        {
          title: 'should contain db_names',
          attr: 'db_names',
          value: ['test', 'prod_db'],
          match: [%r{CONFIG_db_names=\( 'test' 'prod_db' \)}],
        },
        {
          title: 'should contain db_month_names',
          attr: 'db_month_names',
          value: ['prod_db', 'prod_db2'],
          match: [%r{CONFIG_db_month_names=\( 'prod_db' 'prod_db2' \)}],
        },
        {
          title: 'should contain db_exclude',
          attr: 'db_exclude',
          value: ['dev_db', 'stage_db'],
          match: [%r{CONFIG_db_exclude=\( 'dev_db' 'stage_db' \)}],
        },
        {
          title: 'should contain table_exclude',
          attr: 'table_exclude',
          value: ['sessions', 'temp'],
          match: [%r{CONFIG_table_exclude=\( 'sessions' 'temp' \)}],
        },
        {
          title: 'should contain do_monthly',
          attr: 'do_monthly',
          value: '05',
          match: [%r{CONFIG_do_monthly='05'}],
        },
        {
          title: 'should contain do_weekly',
          attr: 'do_weekly',
          value: 2,
          match: [%r{CONFIG_do_weekly='2'}],
        },
        {
          title: 'should contain rotation_daily',
          attr: 'rotation_daily',
          value: 4,
          match: [%r{CONFIG_rotation_daily='4'}],
        },
        {
          title: 'should contain rotation_weekly',
          attr: 'rotation_weekly',
          value: 45,
          match: [%r{CONFIG_rotation_weekly='45'}],
        },
        {
          title: 'should contain rotation_monthly',
          attr: 'rotation_monthly',
          value: 230,
          match: [%r{CONFIG_rotation_monthly='230'}],
        },
        {
          title: 'should contain mysql_dump_commcomp',
          attr: 'mysql_dump_commcomp',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_commcomp='yes'}],
        },
        {
          title: 'should contain mysql_dump_usessl',
          attr: 'mysql_dump_usessl',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_usessl='yes'}],
        },
        {
          title: 'should contain mysql_dump_socket',
          attr: 'mysql_dump_socket',
          value: '/tmp/none.sock',
          match: [%r{CONFIG_mysql_dump_socket='/tmp/none.sock'}],
        },
        {
          title: 'should contain mysql_dump_max_allowed_packet',
          attr: 'mysql_dump_max_allowed_packet',
          value: 2048,
          match: [%r{CONFIG_mysql_dump_max_allowed_packet='2048'}],
        },
        {
          title: 'should contain mysql_dump_buffer_size',
          attr: 'mysql_dump_buffer_size',
          value: '300',
          match: [%r{CONFIG_mysql_dump_buffer_size='300'}],
        },
        {
          title: 'should contain mysql_dump_single_transaction',
          attr: 'mysql_dump_single_transaction',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_single_transaction='yes'}],
        },
        {
          title: 'should contain mysql_dump_master_data',
          attr: 'mysql_dump_master_data',
          value: 1,
          match: [%r{CONFIG_mysql_dump_master_data='1'}],
        },
        {
          title: 'should contain mysql_dump_full_schema',
          attr: 'mysql_dump_full_schema',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_full_schema='yes'}],
        },
        {
          title: 'should contain mysql_dump_dbstatus',
          attr: 'mysql_dump_dbstatus',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_dbstatus='yes'}],
        },
        {
          title: 'should contain mysql_dump_create_database',
          attr: 'mysql_dump_create_database',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_create_database='yes'}],
        },
        {
          title: 'should contain mysql_dump_use_separate_dirs',
          attr: 'mysql_dump_use_separate_dirs',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_use_separate_dirs='yes'}],
        },
        {
          title: 'should contain mysql_dump_compression',
          attr: 'mysql_dump_compression',
          value: 'bzip2',
          match: [%r{CONFIG_mysql_dump_compression='bzip2'}],
        },
        {
          title: 'should contain mysql_dump_latest',
          attr: 'mysql_dump_latest',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_latest='yes'}],
        },
        {
          title: 'should contain mysql_dump_latest_clean_filenames',
          attr: 'mysql_dump_latest_clean_filenames',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_latest_clean_filenames='yes'}],
        },
        {
          title: 'should contain mysql_dump_differential',
          attr: 'mysql_dump_differential',
          value: 'yes',
          match: [%r{CONFIG_mysql_dump_differential='yes'}],
        },
        {
          title: 'should contain mailcontent',
          attr: 'mailcontent',
          value: 'nonegiven',
          match: [%r{CONFIG_mailcontent='nonegiven'}],
        },
        {
          title: 'should contain mail_maxattsize',
          attr: 'mail_maxattsize',
          value: 40,
          match: [%r{CONFIG_mail_maxattsize='40'}],
        },
        {
          title: 'should contain mail_splitandtar',
          attr: 'mail_splitandtar',
          value: 'no',
          match: [%r{CONFIG_mail_splitandtar='no'}],
        },
        {
          title: 'should contain mail_use_uuencoded_attachments',
          attr: 'mail_use_uuencoded_attachments',
          value: 'no',
          match: [%r{CONFIG_mail_use_uuencoded_attachments='no'}],
        },
        {
          title: 'should contain mail_address',
          attr: 'mail_address',
          value: 'root@example.com',
          match: [%r{CONFIG_mail_address='root@example.com'}],
        },
        {
          title: 'should contain encrypt',
          attr: 'encrypt',
          value: 'yes',
          match: [%r{CONFIG_encrypt='yes'}],
        },
        {
          title: 'should contain encrypt_password',
          attr: 'encrypt_password',
          value: 'supersecret',
          match: [%r{CONFIG_encrypt_password='supersecret'}],
        },
        {
          title: 'should contain backup_local_files',
          attr: 'backup_local_files',
          value: ['/etc/motd', '/etc/hosts'],
          match: [%r{CONFIG_backup_local_files=\( '\/etc\/motd' '\/etc\/hosts' \)}],
        },
        {
          title: 'should contain prebackup',
          attr: 'prebackup',
          value: '/usr/local/bin/myscript',
          match: [%r{CONFIG_prebackup='\/usr\/local\/bin\/myscript'}],
        },
        {
          title: 'should contain postbackup',
          attr: 'postbackup',
          value: '/usr/local/bin/myotherscript',
          match: [%r{CONFIG_postbackup='\/usr\/local\/bin\/myotherscript'}],
        },
        {
          title: 'should contain umask',
          attr: 'umask',
          value: '0020',
          match: [%r{CONFIG_umask='0020'}],
        },
        {
          title: 'should contain dryrun',
          attr: 'dryrun',
          value: 'no',
          match: [%r{CONFIG_dryrun='no'}],
        },
      ].each do |param|
        describe "when #{param[:attr]} is #{param[:value]}" do
          let(:params) { default_params.merge(param[:attr].to_sym => param[:value]) }

          it { is_expected.to contain_file("#{params[:etc_dir]}/#{title}.conf").with_mode('0650') }
          if param[:match]
            it "#{param[:title]}: matches" do
              param[:match].each do |match|
                is_expected.to contain_file("#{params[:etc_dir]}/#{title}.conf").with_content(match)
              end
            end
          end
        end
      end
    end
  end
end
