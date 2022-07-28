require 'spec_helper'

TITLE = '[cacti設定]-'

describe "#{TITLE}[1]:cacti動作に必要となるnativeパッケージのインストール状態確認" do
  COMMON['native_packages'].each do |target|
    describe package(target), :if => os[:family] == 'ubuntu' do
      it { should be_installed }
    end
  end
end
