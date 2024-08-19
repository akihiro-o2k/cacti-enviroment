require 'spec_helper'

describe '[1]mariadb-serverパッケージがインストールされている事::' do
  describe package('mariadb-server'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
end
describe "[2]指定バージョン'#{COMMON['mariadb_version']}'でインストールされている事::" do
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} --version") do
    its(:stdout)  { should match /11.4.3-MariaDB/ }
  end
end
describe '[3]systemd関連:mariadbの起動と再起動時の動作を確認::' do
  describe service('mariadb'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled   }
    it { should be_running   }
  end
end
describe '[4]mariadb用ポート有効化判定::' do 
  describe port(3306) do
    it { should be_listening.on('127.0.0.1').with('tcp') }
  end
end
describe "[5]rootユーザーでmysqlshow実行結果::" do
  grant = %w(cactidb information_schema mysql performance_schema sys)
  describe command("mysqlshow -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']}") do
    grant.each do |param|
      its(:stdout)  { should match /#{param}/ }
    end
  end
end
describe "[6]#{COMMON['db_user_name']}ユーザーのmysqlshow実行結果::" do
  describe command("mysqlshow -u#{COMMON['db_user_name']} -p#{COMMON['db_user_password']} -h#{COMMON['bind-address']}") do
     %w(cactidb information_schema mysql).each do |param|
      its(:stdout)  { should match /#{param}/ }
    end
  end
end
describe '[7]configracion params check::' do
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep collation_server|xargs") do
    its(:stdout)  { should match /utf8mb4_unicode_ci/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep character_set_server|xargs") do
    its(:stdout)  { should match /utf8mb4/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep max_heap_table_size|xargs") do
    its(:stdout)  { should match /#{ENVIROMENT['max_heap_table_size']}/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep tmp_table_size|xargs") do
    its(:stdout)  { should match /#{ENVIROMENT['tmp_table_size']}/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep innodb_file_per_table|xargs") do
    its(:stdout)  { should match /ON/ }
  end
end
describe "[7]sql_batch_01の実行結果確認(show tables結果を文字列合致で確認)::" do
  cactidb_tables = YAML.load_file('extraction/cactidb_tables.yml')['cactidb_tables']
  describe command("mysql -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} #{COMMON['database']} -e 'show tables;'") do
    cactidb_tables.each do |table|
      its(:stdout)  { should match /#{table}/ }
    end
  end
end

describe "[8]sql_batch_x02の実行結果確認(insert結果をユニーク値合致で確認)::" do
  # time_zoneテーブルのユニーク値が全て取得できるか確認。
  time_zone = %w(MET UTC Universal  Europe/Moscow leap/Europe/Moscow Japan)
  describe command("mysql -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} mysql -e 'select * from time_zone_name;'") do
    time_zone.each do |local|
      its(:stdout)  { should match /#{local}/ }
    end
  end
  actual = %w(1N 2N 3N 4Y 5N)
  describe command("mysql -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} mysql -e 'select concat(Time_zone_id, Use_leap_seconds) val from mysql.time_zone;'") do
    actual.each do |val|
      its(:stdout)  { should match /#{val}/ }
    end
  end
  # time_zone_transition_typeのテーブルでユニークになる文字列にconcatして全レコードが存在するか確認。
  time_zone_transition_type=YAML.load_file('extraction/cactidb_tables.yml')['time_zone_transition_type']
  sql = "select distinct concat(Time_zone_id, '-', Transition_type_id,'-',Abbreviation) zones from time_zone_transition_type;"
  describe command("mysql -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} mysql -e \"#{sql}\"") do
    time_zone_transition_type.each do |value|
      its(:stdout)  { should match /#{value}/ }
    end
  end
  # time_zone_transitionテーブルでユニークとなる文字列にconcatして全レコードが存在するか確認。
  time_zone_transition=YAML.load_file('extraction/time_zone_transition.yml')['time_zone_transition']
  sql = "select distinct concat(Time_zone_id,':',Transition_time) uniq from time_zone_transition;"
  describe command("mysql -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} mysql -e \"#{sql}\"") do
    time_zone_transition.each do |value|
      its(:stdout)  { should match /#{value}/ }
    end
  end
end
