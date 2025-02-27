require 'spec_helper'

# test Ubuntu version
describe "[1]:/etc/profile.d/proxy_setting.shの存在確認::" do
  describe file('/etc/profile.d/proxy_setting.sh') do
    if ENV['ENVIROMENT']!='development' then
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
describe "[2]:/etc/apt/sources.listの存在確認::" do
  describe file('/etc/apt/sources.list') do
    if ENV['ENVIROMENT']!='development' then
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
describe "[3]:/etc/apt/apt.conf.d/30proxyの存在確認::" do
  describe file('/etc/apt/apt.conf.d/30proxy') do
    if ENV['ENVIROMENT']!='development' then
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
