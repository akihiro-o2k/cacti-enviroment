require 'spec_helper'

# 定数定義
PHP_INI = { :ini => COMMON['php_ini_path'] }.freeze

describe '[1]apache2パッケージがインストールされている事::' do
  describe package('apache2'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
end
describe "[2]標準催促別紙要件:インストールしたApacheのバージョンが2.4系である事::" do
  describe command("/usr/sbin/apache2ctl -v") do
    its(:stdout)  { should match /^Server version: Apache\/2.4.*/ }
  end
end

describe '[3]systemd関連。インストール済みサービスapache2の状態確認::' do
  describe service('apache2'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled }
    it { should be_running }
  end
end

describe '[4]apache2用ポートlisten設定状態の確認::' do 
  describe port(80) do
    it { should be_listening }
    it { should be_listening.with('tcp6') }
  end
end

describe "[5]/etc/apache2/apache2.confの設定内容を正規表現フックで確認::" do
  describe file('/etc/apache2/apache2.conf') do
    accept = "ServerName #{host_inventory['hostname']}"
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    # 独自設定箇所
    its(:content) { should match /#{accept}/ }
    # TODO:業務要件の妥当性確認(ErrorLogの出力無効化の方式の良否判定)
    its(:content) { should match /ErrorLog \/dev\/null/ }
  end
end


describe "[6]/etc/apache2/sites-available/000-default.confの設定内容を正規表現フックで確認::" do
  describe file('/etc/apache2/sites-available/000-default.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /ErrorLog \/dev\/null/ }
  end
end
# phpモジュールのインストール状態確認
describe '[7]cacti動作に必要となるphpパッケージのインストール状態確認::' do
  COMMON['php_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end

describe '[8]PHP_config関連のテスト::' do
  # php.ini事態の存在確認。
  describe file(COMMON['php_ini_path']) do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    # TODO:max_execution_timeパラメータのみphp_config用テストメソッドでフック出来なかった為正規表件で確認。
    its(:content) { should match /max_execution_time = #{COMMON['php_max_execution_time']}/ }
  end
  # TODO:各種PHP設定パラメータの妥当性確認及び、不足があれば外部パラメータ化してserverspec/ansibleへ反映。
  context  php_config('memory_limit', PHP_INI) do
    its(:value) { should eq COMMON['php_memory_limit'] }
  end
  context  php_config('date.timezone', PHP_INI) do
    its(:value) { should eq COMMON['time_zone'] }
  end
end
