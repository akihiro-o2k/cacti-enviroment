require 'spec_helper'

describe 'mariadbパッケージがインストールされている事。' do
  describe package('mariadb'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
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

### ポイント: ポートが特定のIPアドレスでListenしているか確認（2.0からの新機能） ###


db_user = "visualize"
db_password = "Visualize00330033"

describe command("mysqlshow -u#{db_user} -p#{db_password}") do
  it { should return_stdout /zabbix/ }
end

describe command("mysqlshow -u#{db_user} -p#{db_password} cacti") do
  it { should return_stdout /hosts/ }
end

describe command("mysqladmin -u#{db_user} -p#{db_password} variables |grep character_set_server") do
  it { should return_stdout /utf8/ }
end
=end
