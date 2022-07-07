require 'spec_helper'

# /etc/hostsファイルが存在する事
describe file('/etc/hosts') do
  it { should be_file }
end

#'名前解決用に各種サーバー名が定義されている事。'
describe file('/etc/hosts') do
  it { should contain 'cacti01' }
  it { should contain 'cacti02' }
end
