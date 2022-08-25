# MWのパラメータ設定

## Apache

## php

- パラメータ設定ファイル
  - /etc/php/8.1/apache2/php.ini
  - /etc/php/8.1/cli/php.ini

|No|パラメータ|変数名|
|1|max_execution_time|php_max_execution_time|
|2|memory_limit|php_memory_limit|
|3|date.timezone|time_zone|

## Mariadb

- パラメータ設定ファイル: /etc/mysql/mariadb.conf.d/50-server.cnf

|No|パラメータ|変数名[^1]|
|--|----------|--|----|
|1|character-set-server|utf8mb4|character_set_server|
|2|collation-server|utf8mb4_unicode_ci|collation_server|
|3|innodb_buffer_pool_size|1G||


### 備考
[^1]該当欄が空白の場合、変数名はパラメータと同一の値とする。

