require 'yaml'
require 'spec_helper'

# 定数定義
PARAMS = YAML.load_file('spec/vars/common.yml').freeze
PHP_INI = { :ini => PARAMS[2]['php_ini_path'] }.freeze

describe 'apache2.4パッケージがインストールされている事。' do
  describe package('apache2'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
    # it { should be_enabled }
    # it { should be_running }
  end
end

describe 'systemd関連。インストール済みサービスapache2の状態確認' do
  describe service('apache2'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'apache2用ポートlisten設定状態の確認' do 
  describe port(80) do
    it { should be_listening }
    it { should be_listening.with('tcp6') }
  end
end
=begin
# httpd.confの設定に関して正規表現でチェック。
describe file('/etc/apache2/apache2.conf') do
  it { should be_file }
  its(:content) { should match /IncludeOptional conf-enabled \/\*\.conf/ }
end
=end

# phpモジュールのインストール状態確認
describe 'cacti動作に必要となるphpパッケージのインストール状態確認' do
  PARAMS[1]['php_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end

describe 'PHP_config関連のテスト' do
  # php.ini事態の存在確認。
  describe file(PARAMS[2]['php_ini_path']) do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
  context  php_config('default_mimetype', PHP_INI) do
    its(:value) { should eq 'text/html' }
  end
  context php_config('session.cache_expire', PHP_INI) do
    its(:value) { should eq 180 }
  end
  context php_config('mbstring.http_output_conv_mimetypes', PHP_INI) do
    its(:value) { should match /application/ }
  end
end
