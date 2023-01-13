require 'spec_helper'


describe "[1]:spine動作に必要となるnativeパッケージのインストール状態確認::" do
  COMMON['spine_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
describe "[2]spineパッケージ解凍ファイル郡の存在確認::" do
  describe file('/usr/local/spine') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
describe "[3]spine実行ファイルの確認::" do
  describe file('/usr/local/spine/bin/spine') do
    it { should be_directory }
    it { should be_mode 4755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
describe "[4]spineDB設定ファイルの確認::" do
  describe file('/usr/local/spine/etc/spine.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /DB_Database\ "#{COMMON['database']}"/ }
    its(:content) { should match /DB_User\ "#{COMMON['db_user_name']}"/ }
  end
end

