require 'spec_helper'

# apache2パッケージがインストールされている事。
describe package('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

# apache2が起動時に有効化設定されており、動作している事。
describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

# 80番ポートがListenになっている事。
describe port(80) do
  it { should be_listening }
end

# httpd.confの設定に関して正規表現でチェック。
describe file('/etc/apache2/apache2.conf') do
  it { should be_file }
  its(:content) { should match /IncludeOptional conf-enabled \/\*\.conf/ }
end

# phpモジュールのインストール状態確認
describe command('apachectl -M |grep php5_module') do
  it { should return_stdout /php5_module/ }
end

