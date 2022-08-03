require 'spec_helper'

describe 'mariadb-serverパッケージがインストールされている事。' do
  describe package('mariadb-server'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
  describe "指定バージョン'#{COMMON['mariadb_version']}'でインストールされている事" do
    describe command("apt list --installed | grep mariadb-server-#{COMMON['mariadb_version']}") do
      # mariadb-server-10.8/
      its(:stdout)  { should match /^mariadb-server-10.8\// }
    end
  end
end
describe 'systemd関連:mariadbの起動と再起動時の動作を確認' do
  describe service('mariadb'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled   }
    it { should be_running   }
  end
end
describe 'mariadb用ポート有効化判定' do 
  describe port(3306) do
    it { should be_listening.on('127.0.0.1').with('tcp') }
  end
end
=begin
describe 'MySQL config parameters' do
  context mysql_config('innodb-buffer-pool-size') do
    its(:value) { should > 10000 }
  end

  context mysql_config('socket') do
    its(:value) { should eq '/tmp/mysql.sock' }
  end
end
=end
describe "mariadb userの参照可能DB確認" do
  describe "rootユーザーでmysqlshow実行結果:" do
    grant = %w(cactidb information_schema mysql performance_schema sys)
    describe command("mysqlshow -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']}") do
      grant.each do |param|
        its(:stdout)  { should match /#{param}/ }
      end
    end
  end
end
describe "#{COMMON['db_user_name']}ユーザーのmysqlshow実行結果:" do
  describe command("mysqlshow -u#{COMMON['db_user_name']} -p#{COMMON['db_user_password']} -h#{COMMON['bind-address']}") do
     %w(cactidb information_schema).each do |param|
      its(:stdout)  { should match /#{param}/ }
    end
  end
end
describe 'configracion params check:' do
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep collation_server") do
    its(:stdout)  { should match /utf8mb4_general_ci/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep character_set_server") do
    its(:stdout)  { should match /utf8mb4/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep max_heap_table_size") do
    its(:stdout)  { should match /16777216/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep tmp_table_size") do
    its(:stdout)  { should match /16777216/ }
  end
  describe command("mysqladmin -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']} variables |grep innodb_file_per_table") do
    its(:stdout)  { should match /ON/ }
  end
end
