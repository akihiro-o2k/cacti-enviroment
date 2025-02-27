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
describe '[4]ruby関連のインストール状態確認::' do
  describe file('/usr/lib/rbenv/shims/ruby') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
describe "[5]rubyバージョンが標準催促適合のバージョン#{COMMON['ruby_version']}か確認::" do
  describe command('/usr/lib/rbenv/shims/ruby -v') do
    its(:stdout) { should match /#{COMMON['ruby_version']}/ }
  end
end
describe '[6]ruby gemパッケージのインストール状態を確認::' do
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
describe '[7]pythonバージョンが標準催促適合のバージョン3.10以上か確認' do
  describe command('python -V') do
    its(:stdout) { should match /^Python 3.10*/ }
  end
end
