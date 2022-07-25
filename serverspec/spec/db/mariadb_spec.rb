require 'spec_helper'

describe 'mariadb-serverパッケージがインストールされている事。' do
  describe package('mariadb-server'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
  describe command("apt list --installed | grep mariadb-server-#{COMMON['mariadb_version']}") do
    # mariadb-server-10.8/
    its(:stdout)  { should match /^mariadb-server-10.8\// }
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
=begin
describe command("mysqlshow -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']}") do
  it { should return_stdout /cacti/ }
end
=end
describe "rootユーザーのmysqlshow実行結果:配列のDBが表示される事" do
  array = %w(cacti information_schema mysql performance_schema sys)
  describe command("mysqlshow -uroot -p#{COMMON['mysql_root_password']} -h#{COMMON['bind-address']}") do
    array.each do |param|
      its(:stdout)  { should match /#{param}/ }
    end
  end
end
describe "#{COMMON['db_user_name']}ユーザーのmysqlshow実行結果:配列のDBが表示される事" do
  describe command("mysqlshow -u#{COMMON['db_user_name']} -p#{COMMON['db_user_password']} -h#{COMMON['bind-address']}") do
     %w(cacti information_schema).each do |param|
      its(:stdout)  { should match /#{param}/ }
    end
  end
end


=begin
describe command("mysql -u#{COMMON['db_user_name']} -p#{COMMON['db_user_password']} cacti") do
  it { should return_stdout /hosts/ }
end

describe command("mysqladmin -u#{COMMON['db_user_name']} -p#{COMMON['db_user_password']} variables |grep character_set_server") do
  it { should return_stdout /utf8mb4/ }
end
=end
