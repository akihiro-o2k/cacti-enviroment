require 'spec_helper'

# nginxがインストールされていること
describe package('nginx'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

# nginxのサービス状態確認
describe service('nginx'), :if => os[:family] == 'ubuntu' do
  # 起動時オプションが有効化されている事
  it { should be_enabled }
  # サービスが起動している事
  it { should be_running }
end

# ポート番号の状態確認
describe port(80) do
  it { should be_listening }
end
