require 'spec_helper'

describe "[1]:provisioning-VM動作に必要となるnativeパッケージのインストール状態確認::" do
  COMMON['provisioning_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
describe '[2]google-chrome-stableパッケージがインストールされている事::' do
  vers = nil
  describe package('google-chrome-stable'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
  describe command("google-chrome --version | cut -d' ' -f3") do
    its(:stdout) { should match COMMON['var_chrome_version'] }
  end 
end
describe '[3]chromodriverインストール状態の確認::' do
  describe file('/usr/local/bin/chromedriver') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
  describe command('chromedriver --version') do
    its(:stdout) { should match COMMON['var_chrome_version'] }
  end
end
describe '[4]rubyバージョン抽象化アプリケーションrbenvインストール状態確認::' do
  describe file('/usr/lib/rbenv') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'develop' }
    it { should be_grouped_into 'develop' }
  end
  context 'rbenvコマンド実行が可能であること' do
    describe command('/usr/lib/rbenv/bin/rbenv --version') do
      its(:stdout) { should match /^rbenv */ }
    end
  end
  context '/etc/profile.d/rbenv.shが配備されており、ログインユーザにrbenv設定が適用できている事::' do
    describe file('/etc/profile.d/rbenv.sh') do
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
describe '[5]ruby関連のインストール状態確認::' do
  describe file('/usr/lib/rbenv/shims/ruby') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
describe "[6]rubyバージョンが標準催促適合のバージョン#{COMMON['ruby_version']}か確認::" do
  describe command('/usr/lib/rbenv/shims/ruby -v') do
    its(:stdout) { should match /#{COMMON['ruby_version']}/ }
  end
end
describe '[7]ruby gemパッケージのインストール状態を確認::' do
  cmd = "/usr/lib/rbenv/versions/#{COMMON['ruby_version']}/bin/gem list"
  # selenium-webdriver
  describe command(cmd) do
    its(:stdout) { should match /selenium-webdriver*/ }
  end
  # serverspec
  describe command(cmd) do
    its(:stdout) { should match /serverspec*/ }
  end
end
describe '[8]pythonバージョンが標準催促適合のバージョン3.10以上か確認' do
  describe command('python -V') do
    its(:stdout) { should match /^Python 3.10*/ }
  end
end
describe '[9]サーバープロビジョニングツールansibleがインストールされ使用可能である事::' do
  describe command('ansible --version') do
    its(:stdout) { should match /^ansible\ \[core*/ }
  end
end
describe '[10]ファイルの動的伝搬を実現するlsyncdの状態確認事::' do
  describe package('lsyncd'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
    #it { should be_enabled }
    #it { should be_running }
  end
  describe file('/etc/lsyncd/lsyncd.conf.lua') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
  context 'ssh接続を実現する為のssh-ed25519鍵が配備されている事' do
    describe file('/home/develop/.ssh/id_ed25519') do
      it { should be_file }
      it { should be_mode 600 }
      it { should be_owned_by 'develop' }
      it { should be_grouped_into 'develop' }
    end
    describe file('/home/develop/.ssh/id_ed25519.pub') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'develop' }
      it { should be_grouped_into 'develop' }
    end
  end
  context 'ssh接続設定ファイルが配備されている事' do
    describe file('/home/develop/.ssh/config') do
      it { should be_file }
      it { should be_mode 664 }
      it { should be_owned_by 'develop' }
      it { should be_grouped_into 'develop' }
    end
  end
end
describe '[11]見える化VM群をデプロイする為のansible/serverspecソースの存在確認' do
  describe file('/home/develop/cacti-enviroment') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'develop' }
    it { should be_grouped_into 'develop' }
  end
end
describe '[12]コンテンツ提供を実現する為のseleniumスクリプトの存在確認' do
  describe file('/usr/local/selenium') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'develop' }
    it { should be_grouped_into 'develop' }
  end
  context 'コンテンツ提供のためのディレクトリ設定状態の確認' do
    describe file('/var/www/images') do
      it { should be_directory }
      it { should be_mode 775 }
      it { should be_owned_by 'www-data' }
      it { should be_grouped_into 'www-data' }
    end
    describe file('/var/www/images/backlog') do
      it { should be_directory }
      it { should be_mode 775 }
      it { should be_owned_by 'www-data' }
      it { should be_grouped_into 'www-data' }
    end
    describe file('/var/www/images/debug/logs') do
      it { should be_directory }
      it { should be_mode 775 }
      it { should be_owned_by 'www-data' }
      it { should be_grouped_into 'www-data' }
    end

  end
end

