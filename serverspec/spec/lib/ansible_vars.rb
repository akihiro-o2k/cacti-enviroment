require 'yaml'

# Ansibleの変数格納用YAMLファイルの第一階層は配列となっている為serverspecでは
# 呼び出し後に配列のindexを指定後にhashキー名称を指定といった使いにくさがある為、
# 配列のインデックスとして格納されてる各種hashの親配列を取り除き、
# 子階層に存在したhashのキー名称で値を取得する為のヘルパーメソッド。
#
# [使用方法]
# CONSTANTS = AnsibleVars.to_hash('file_path')
#
# [補足説明]
# spec_helper.rb内部で読み込みたいansibleのyamlを上記方式で定数へと代入。
# -> 各serverspecはspec_helerをrequireしているので個別での読み込み定義が不要となる。
#
class AnsibleVars
  def self.to_hash(file_path)
    return  nil unless FileTest.exist?(file_path)

    # 戻り値格納用変数
    hash = {}
    YAML.load_file(file_path).each do |array|
      array.each { |key, val| hash[key] = val }
    end
    hash
  end
end
