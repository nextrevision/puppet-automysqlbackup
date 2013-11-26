require 'spec_helper_system'

describe 'basic tests' do
  it 'class should work without errors' do
    pp = <<-EOS
      package { 'mysql-server':
        ensure => present,
        before => Class['automysqlbackup'],
      }
      if $::osfamily == "RedHat" {
        service { 'mysqld':
          ensure  => running,
          before  => Class['automysqlbackup'],
        }
      }
      class { 'automysqlbackup':
        backup_dir        => '/mnt/backups',
      }
      automysqlbackup::backup { 'automysqlbackup':
        mysql_dump_username => 'root',
        do_monthly          => '0',
        do_weekly           => '0',
        db_exclude          => ['performance_schema','information_schema'],
        table_exclude       => ['mysql.event'],
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should be_zero
    end
  end
  it 'should run automysqlbackup' do
    shell '/etc/cron.daily/automysqlbackup-automysqlbackup' do |r|
      r.stdout.should =~ /Backup End Time/
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end
  it 'should create backup mysql backup file' do
    shell 'test -f /mnt/backups/automysqlbackup/daily/mysql/daily_mysql*' do |r|
      r.stderr.should be_empty
      r.exit_code.should be_zero
    end
  end
end
