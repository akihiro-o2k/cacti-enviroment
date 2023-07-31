require 'spec_helper'
describe "[1]directory存在確認::" do
  describe file('/var/www/images') do
    it { should be_directory }
    it { should be_mode 775 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
  describe file('/var/www/images/backlog') do
    it { should be_directory }
    it { should be_mode 775 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
end
describe "[2]/etc/apache2/sites-available/images.confの確認::" do
  describe file('/etc/apache2/sites-available/images.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
describe "[3]apache2 virtual host link-file設定確認::" do
  describe file('/etc/apache2/sites-enabled/images.conf') do
    it { should be_symlink }
  end
end
