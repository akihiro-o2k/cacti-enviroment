require 'serverspec'
require 'net/ssh'
require 'lib/ansible_vars'

# 全体的用する定数を読み込み
COMMON = AnsibleVars.to_hash('spec/vars/common.yml').freeze
ENVIROMENT = AnsibleVars.to_hash("spec/vars/#{ENV['ENVIROMENT']}.yml").freeze

set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end
host = ENV['TARGET_HOST']
options = Net::SSH::Config.for(host)

# ssh公開鍵認証に対応する為の追記
# https://blog.kakakikikeke.com/2015/04/serverspec-passphrase-ssh.html
options[:keys] = ENV['KEY'];
options[:user] = ENV['USER'] || Etc.getlogin
set :sudo_password, ENV['SUDO_PASSWD']

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

