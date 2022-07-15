require 'yaml'

# AnsibleのYAMLファイル構造が配列を基本としておりserverspecで扱いにくい為、
# 配列のインデックスとして格納されてる各種hashに対して親配列を取り除いて戻すライブラリ
class AnsibleVars
  # クラスメソッド化して、少ないタイプ数で実行させる。
  def self.to_hash(file)
    return  nil unless FileTest.exist?(file)
    yaml = YAML.load_file(file)
    hash = {}
    yaml.each do |array|
      array.each { |key, val| hash[key] = val }
    end
    hash
  end
end
