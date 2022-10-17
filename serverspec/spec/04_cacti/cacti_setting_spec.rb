require 'spec_helper'


describe "[1]:cacti動作に必要となるnativeパッケージのインストール状態確認::" do
  COMMON['native_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
describe "[2]cactaiパッケージ解凍ファイル郡の存在確認::" do
  describe file("#{COMMON['cacti_root_path']}") do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
end
describe "[3]apache2 virtualhost 設定ファイルの確認::" do
  describe file('/etc/apache2/sites-available/cacti.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /Alias \/cacti/ }
    its(:content) { should match /Directory\ \/var\/www\/cacti/ }
  end
end
describe "[4]apache2 virtual host link-file設定確認::" do
  describe file('/etc/apache2/sites-enabled/cacti.conf') do
    it { should be_symlink }
  end
end

describe "[5]/var/www/cacti/include/config.php(mariadb接続設定ファイル)の確認::" do
  actuals = ["database_default  = '#{COMMON['database']}'", "database_username = '#{COMMON['db_user_name']}'", "database_password = '#{COMMON['db_user_password']}'"]
  describe file('/var/www/cacti/include/config.php') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
    actuals.each do |param| 
      its(:content) { should match /^\$#{param}/ }
    end
  end
end


describe '[6]NXXXXXXが指定する、共通網、業務網内のNWノードをDevice登録し、SNMPによる情報取得ができること。（FW遮断などネットワーク要因の場合は除く）::' do
  pending
end

describe '[7]登録したDeviceにおいて問題なくGraph設定が実施でき、グラフの描画が正常であること::' do
  pending
end

describe '[8]Deviceの削除が問題なく実施できること::' do
  pending
end

describe '[9]任意のUserを登録し、正常に登録完了すること::' do
  pending
end

describe '[10]Userに設定したロールに関し、指定した権限以外の処理ができないこと::' do
  pending
end

describe '[11]Userの削除が問題なく実施できること::' do
  pending
end
