require 'spec_helper'


describe "[1]:cacti動作に必要となるnativeパッケージのインストール状態確認" do
  COMMON['native_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
describe "[2]cactaiのファイル存在確認" do
  describe file("#{COMMON['cacti_root_path']}") do
    it { should be_directory }
    it { should be_mode 640 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
end
describe "[3]apache2 virtual host file設定確認" do
  describe file('/etc/apache2/sites-available/cacti.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /Alias \/cacti/ }
    its(:content) { should match /Directory\ \/var\/www\/cacti/ }
  end
end
