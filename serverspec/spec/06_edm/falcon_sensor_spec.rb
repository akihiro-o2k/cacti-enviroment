require 'spec_helper'
if ENV['ENVIROMENT'] == 'production'
  describe "[1]:falcon-sensorパッケージのインストール状態確認::" do
    describe package('falcon-sensor'), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
  describe "[2]falcon-sensorの動作確認::" do
    describe process("falcon-sensor") do
      it { should be_running }
      it { should be_enabled }
    end
  end
  describe "[3]falcon-sensorのlogrotate設定の確認::" do
    describe file('/etc/logrotate.d/falcon-sensor') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match /rotate 24/ }
      its(:content) { should match /monthly/ }
    end
  end
end
