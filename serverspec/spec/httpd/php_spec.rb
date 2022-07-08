require 'spec_helper'

# PHP設定配列。配列の値はキー名称と設定値でハッシュ化
php_values = [{'max_execution_time' => 300},
              {'memory_limit' => '128M'},
              {'post_max_size' => '16M'},
              {'upload_max_filesize' => '2M'},
              {'max_input_time' => 300},
              {'date.timezone' => 'Asia/Tokyo'}]

describe 'PHP config parameters' do
  # php configに対してphp_valuesのインデックスでループ処理。
  php_values.each do |php_value|
    context php_config(php_value.keys.first) do
      its(:value) { should eq php_value[php_value.keys.first] }
    end
  end
end
