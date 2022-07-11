require 'spec_helper'

describe 'apache2.4パッケージがインストールされている事。'
  describe package('apache2'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
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
describe command('apachectl -M |grep libapache2-mod-php8.0') do
  it { should return_stdout /php8.0_module/ }
end

