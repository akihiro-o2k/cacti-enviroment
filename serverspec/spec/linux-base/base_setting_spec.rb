require 'spec_helper'

# test Ubuntu version
describe "OS のバージョンは Ubuntu 20.04 であることを確認する" do
  describe command("lsb_release -a") do
    its(:stdout) { should match /Ubuntu 20.04/ }
  end
end

# /etc/hostsファイルが存在する事
describe file('/etc/hosts') do
  it { should be_file }
end

# 名前解決用に各種サーバー名が定義されている事。
describe file('/etc/hosts') do
  it { should contain 'cacti01' }
  it { should contain 'cacti02' }
end

# hostname = host_inventory['hostname']
# 本当に名前解決できているか確認
hosts = %w(cacti01 cacti02 mssql01 mssql02)
hosts.each do |target|
  describe host(target) do
    it { should be_resolvable }
  end
end

# プロンプト色設定ファイルの存在確認
describe file('/etc/profile.d/prompt_coler.sh') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain 'PS1' }
end
