require 'serverspec'
require 'net/ssh'
require 'lib/ansible_vars'
require 'highline/import'
require 'yaml'

set :backend, :ssh

host = ENV['TARGET_HOST']
options = Net::SSH::Config.for(host)

# ssh公開鍵認証に対応する為の追記
# https://blog.kakakikikeke.com/2015/04/serverspec-passphrase-ssh.html
# 諸注意:
# ~/.bashrcに環境変数SSH_KEY及び、SUDO_PASSWDの追記が必須。
options[:keys] = ENV['SSH_KEY'];
options[:user] = ENV['USER'] || Etc.getlogin
set :sudo_password, ENV['SUDO_PASSWD']

set :host,        options[:host_name] || host
set :ssh_options, options

# 全体的用する定数を読み込み
COMMON = AnsibleVars.to_hash('spec/vars/common.yml').freeze
ENVIROMENT = AnsibleVars.to_hash("spec/vars/#{ENV['ENVIROMENT']}.yml").freeze
