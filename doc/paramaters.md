
# MWのパラメータ設定

## Apache

## php

- パラメータ設定ファイル
  - /etc/php/8.1/apache2/php.ini
  - /etc/php/8.1/cli/php.ini

|No|パラメータ|ansible変数名[^1]|
|--|----------|----|
|1|max_execution_time|php_max_execution_time|
|2|memory_limit|php_memory_limit|
|3|date.timezone|time_zone|

## Mariadb

- パラメータ設定ファイル:
  - /etc/mysql/mariadb.conf.d/50-server.cnf

|No|パラメータ|ansible変数名[^1]|
|--|----------|----|
|1|character-set-server|character_set_server|
|2|collation-server|collation_server|
|3|innodb_buffer_pool_size||
|4|max_heap_table_size||
|5|tmp_table_size||


### 備考
[^1]該当欄が空白の場合、変数名はパラメータと同一の値とする。
