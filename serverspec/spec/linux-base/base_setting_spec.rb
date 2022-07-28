require 'spec_helper'

TITLE = '[linux基本設定]-'
# test Ubuntu version
describe "#{TITLE}[1]:OS のバージョンは Ubuntu 20.04 であることを確認する" do
  describe command("lsb_release -a") do
    its(:stdout) { should match /Ubuntu 20.04/ }
  end
end
describe "#{TITLE}[2]:/etc/profile.d/proxy_setting.shの存在確認" do
  describe file('/etc/profile.d/proxy_setting.sh') do
    if ENV['ENVIROMENT']!='development' then
      it { should be_file }
      it { should be_mode 711 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    else
      context '開発環境ではproxyを使用しない為、ファイルは存在しない' do
        it { should_not be_file }
      end
    end
  end
end

# test /etc/hosts
describe "#{TITLE}[3]:/etc/hosts関連設定の確認" do
  hosts = %w(cacti01 cacti02 mssql01 mssql02)
  describe file('/etc/hosts') do
    it { should be_file }
    describe '名前解決用に各種サーバー名が定義されている事。' do
      hosts.each { |host| it { should contain host } }
    end
  end
  describe "/etc/hostsの定義が本当に名前解決できているか確認" do
    hosts.each do |tgt|
      describe host(tgt) do
        it { should be_resolvable }
      end
    end
  end
end


# test /etc/profile.d/prompt_coler.sh
#describe 'プロンプト色設定シェルの設定確認' do
#  describe file('/etc/profile.d/prompt_coler.sh') do
#    it { should be_file }
#    it { should be_mode 644 }
#    it { should be_owned_by 'root' }
#    it { should be_grouped_into 'root' }
#    it { should contain 'PS1' }
#  end
#end

# systemd-timesyncd
describe "#{TITLE}[4]:NTPD(systemd-timesyncd)の起動と再起動時の動作を確認" do
  describe service('systemd-timesyncd'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled   }
    it { should be_running   }
  end
end

describe "#{TITLE}[5]:NTP参照先設定の確認" do
  ENVIROMENT['ntp_servers'].each do |ntpd|
    describe command("timedatectl timesync-status | grep Server") do
      its(:stdout) { should match /#{ntpd}/ }
    end
  end
end

describe "#{TITLE}[6]:timezone設定値が'#{COMMON['time_zone']}'である事" do
  describe command("timedatectl | grep 'Time zone'") do
      its(:stdout) { should match /#{COMMON['time_zone']}/ }
  end
end
