require 'spec_helper'

# test Ubuntu version
describe "[1]:OS のバージョンは Ubuntu 20.04 であることを確認する::" do
  describe command("lsb_release -a") do
    its(:stdout) { should match /Ubuntu 20.04/ }
  end
end
describe "[2]:/etc/profile.d/proxy_setting.shの存在確認::" do
  describe file('/etc/profile.d/proxy_setting.sh') do
    if ENV['ENVIROMENT']!='development' then
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end

# test /etc/hosts
describe "[3]:/etc/hosts関連設定の確認" do
  hosts = %w(cacti01 cacti02 orion01 orion02 orion_db01 cacti03)
  describe file('/etc/hosts') do
    it { should be_file }
    describe '名前解決用に各種サーバー名が定義されている事::' do
      hosts.each { |host| it { should contain host } }
    end
  end
  describe "/etc/hostsの定義が名前解決できているか確認::" do
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
describe "[4]:NTPD(systemd-timesyncd)の起動と再起動時の動作を確認::" do
  describe service('systemd-timesyncd'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled   }
    it { should be_running   }
  end
end

describe "[5]:NTP参照先設定の確認::" do
  ENVIROMENT['ntp_servers'].each do |ntpd|
    describe command("timedatectl timesync-status | grep Server") do
      its(:stdout) { should match /#{ntpd}/ }
    end
  end
end

describe "[6]:timezone設定値が'#{COMMON['time_zone']}'である事::" do
  describe command("timedatectl | grep 'Time zone'") do
      its(:stdout) { should match /#{COMMON['time_zone']}/ }
  end
end

user = COMMON['admin_user'][0]
describe "[7]OS管理用ユーザー'#{user['u_name']}'の設定確認::" do
  describe user("#{user['u_name']}") do
    it { should exist }
    it { should belong_to_primary_group "#{user['u_name']}" }
    it { should belong_to_group 'sudo' }
    it { should have_home_directory "#{user['home']}" }
    it { should have_login_shell "#{user['shell']}" }
  end
end

describe "[8]OS管理用ユーザー'#{user['u_name']}'のhome directory設定確認::" do
  describe file("#{user['home']}") do
    it { should be_directory }
    it { should be_owned_by "#{user['u_name']}" }
    it { should be_grouped_into "#{user['u_name']}" }
    it { should be_mode 755 }
  end
end
