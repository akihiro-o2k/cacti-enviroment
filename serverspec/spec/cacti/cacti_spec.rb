require 'spec_helper'

=begin
describe 'mariadb-serverパッケージがインストールされている事。' do
  describe package('mariadb-server'), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
  describe "指定バージョン'#{COMMON['mariadb_version']}'でインストールされている事" do
    describe command("apt list --installed | grep mariadb-server-#{COMMON['mariadb_version']}") do
      # mariadb-server-10.8/
      its(:stdout)  { should match /^mariadb-server-10.8\// }
    end
  end
end
describe 'systemd関連:mariadbの起動と再起動時の動作を確認' do
  describe service('mariadb'), :if => os[:family] == 'ubuntu' do
    it { should be_enabled   }
    it { should be_running   }
  end
end
=end
