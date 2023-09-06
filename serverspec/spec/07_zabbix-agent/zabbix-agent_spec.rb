require 'spec_helper'
if ENV['ENVIROMENT'] == 'production'
  describe "[1]:zabbix-agentパッケージのインストール状態確認::" do
    describe package('zabbix-agent'), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
  describe "[2]zabbix-agentの動作確認::" do
    describe service("zabbix-agent"), :if => os[:family] == 'ubuntu' do
      it { should be_running }
      it { should be_enabled }
    end
  end
  describe "[3]zabbix_agentd.conf設定の確認::" do
    accept = "Hostname=#{host_inventory['hostname']}"
    describe file('/etc/zabbix/zabbix_agentd.conf') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match /#{accept}/ }
    end
  end
end

