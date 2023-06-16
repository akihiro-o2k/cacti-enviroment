require 'spec_helper'


describe "[1]:cacti動作に必要となるnativeパッケージのインストール状態確認::" do
  COMMON['native_packages'].each do |target|
    next if target == 'libmysql++-dev'
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
describe "[2]cactaiパッケージ解凍ファイル郡の存在確認::" do
  describe file("#{COMMON['cacti_root_path']}") do
    it { should be_directory }
    it { should be_mode 775 }
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

describe "[6] poller設定ファイル(/etc/cron.d/cacti)の確認::" do
  describe file('/etc/cron.d/cacti') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /php\ \/var\/www\/cacti\/poller.php/ }
  end
end

