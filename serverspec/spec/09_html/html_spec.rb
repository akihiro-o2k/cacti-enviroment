require 'spec_helper'
describe "[1]directory存在確認::" do
  describe file('/var/www/html/tm-cacti') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
end
describe "[2]html存在確認::" do
  describe file('/var/www/html/tm-cacti/index.html') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
  describe file('/var/www/html/tm-cacti/office.html') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'www-data' }
    it { should be_grouped_into 'www-data' }
  end
end
