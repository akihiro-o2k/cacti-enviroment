require 'spec_helper'
require 'yaml'

# 定数定義セクション
COMMON = YAML.load_file('spec/vars/common.yml').freeze
ENVIROMENT = YAML.load_file("spec/vars/#{ENV['ENVIROMENT']}.yml").freeze

# test Ubuntu version
describe "OS のバージョンは Ubuntu 20.04 であることを確認する" do
  describe command("lsb_release -a") do
    its(:stdout) { should match /Ubuntu 20.04/ }
  end
end

# test /etc/hosts
describe '/etc/hosts関連設定の確認' do
  hosts = %w(cacti01 cacti02 mssql01 mssql02)
  describe file('/etc/hosts') do
    it { should be_file }
    describe '名前解決用に各種サーバー名が定義されている事。' do
      hosts.each { |host| it { should contain host } }
    end
    describe "/etc/hostsの定義が本当に名前解決できているか確認" do
      hosts.each do |host|
        describe host(host) { it { should be_resolvable } }
      end
    end
  end
end

# test /etc/profile.d/prompt_coler.sh
describe 'プロンプト色設定シェルの設定確認' do
  describe file('/etc/profile.d/prompt_coler.sh') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should contain 'PS1' }
  end
end

describe "NTP参照先設定の確認" do
  ENVIROMENT[2]['ntp_servers'].each do |ntpd|
    describe command("timedatectl timesync-status | grep Server") do
      its(:stdout) { should match /#{ntpd}/ }
    end
  end
end

describe "timezone設定値が'#{COMMON[3]['time_zone']}'である事" do
  describe command("timedatectl | grep 'Time zone'") do
      its(:stdout) { should match /#{COMMON[3]['time_zone']}/ }
  end
end
