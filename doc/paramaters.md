# MWのパラメータ設定

## Apache


## Mariadb

- パラメータ設定ファイル: /etc/mysql/mariadb.conf.d/50-server.cnf

|No|パラメータ|値|備考|
|--|----------|--|----|
|1|character-set-server|utf8mb4|mariadb default|
|2|collation-server|utf8mb4_unicode_ci|[^1]|
|3|innodb_buffer_pool_size|1G||


### 備考
[^1]: cacti configracion画面での指摘で編集

