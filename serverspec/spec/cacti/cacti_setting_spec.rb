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
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
