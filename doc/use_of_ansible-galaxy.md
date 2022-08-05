# ansible-galaxyの利用に関して

- mariadbのインストールに関しては既存ansible-playbookをShereするansible-galaxyで公開されている物を利用した。
  - URL: https://galaxy.ansible.com/mahdi22/mariadb_install
  - Licence: MIT

### 導入手順
- ansibleディレクトリで下記のコマンドを実行。
    ```bash
    # roles配下にDownload
    ansible-galaxy install mahdi22.mariadb_install -i roles/
    # ディレクトリ名が冗長なのでリネーム
    mv roles/mahdi22.mariadb_install/ roles/db/
    ```
### パラメーター設定
- roles/db/README.mdを参考に下記パラメータをvars/common.ymlに追記した。
  - TODO: rootパスワード及びDBユーザーパスワードの値確認及び、文章上でのマスク化の要否を確認。
    ```yaml
    # ansible-galaxy install mahdi22.mariadb_install
    - mariadb_version: "10.8"
    - bind-address: '127.0.0.1'
    - deny_remote_connections: true
    - mysql_root_password: "TrustNo1"
    - create_database: true
    - database: cacti
    - create_db_user: true
    - db_user_name: cactiuser
    - db_user_password: cactiuser
    # 独自改修箇所:ミラーサイトとバージョンを同一URIで変数渡し
    - mariadb_repo: 'deb https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.8/ubuntu'
    - innodb_buffer_pool_size: '1G'
    - import_sql_file: true
    - sql_file_name:
      - { db: 'cactidb', file: '01_criate_cacti_tables.sql' }
      - { db: 'mysql', file: '02_insert_mysql_data_timezone.sql' }
      - { db: 'mysql ', file: '03_grant_select_parmission.sql' }

    ```
### 独自改修箇所
1. roles/db/vars/Ubuntu.yml
    - 変更の概要
      - mariadbを取得しに行くリポジトリが海外なので遅いのと、ハードコーディングでversionを指定していた為、
        変数`mariadb_repo`に国内のミラーサーバーとversionを指定する方式に変更した。
    - code
      - TODO:mainマージ後はURL書き換え
      - [origin:](https://github.com/mahdi22/ansible-mariadb-install/blob/master/vars/Ubuntu.yml)
        ```yaml
        key_url: "https://mariadb.org/mariadb_release_signing_key.asc"
        repo_deb: deb [arch=amd64,arm64,ppc64el] https://mirror.klaus-uwe.me/mariadb/repo/10.4/ubuntu
        mariadb_socket: /run/mysqld/mysqld.sock
        ```
      - [update:](https://github.com/akihiro-o2k/cacti-enviroment/blob/develop/ansible/roles/db/vars/Ubuntu.yml)
        ```yaml
          key_url: "https://mariadb.org/mariadb_release_signing_key.asc"
          # default値のままだとmariadb_varsion変数を参照できなかった為、var/common.yml内部で
          # mariadb_repo変数を定義し、ミラーサーバのURIとインストール対象varsionを定義。
          repo_deb: "{{ mariadb_repo }}"
          ```
1. roles/db/tasks/configure-mariadb.yml
    - 変更の概要
      - mariadb設定ファイルがRedhat/Debian方式には対応していたがUbuntu方式に非対応だった為、
        (Debian用の定義が効くのを避ける為に)Debian用の箇所を消去してUbuntu用の定義を追記。
      - config中の設定値未定義箇所を変数読みできるように改修(現状では`innodb_buffer_pool_size`のみ対応)
    - code
      - [origin:](https://github.com/mahdi22/ansible-mariadb-install/blob/master/tasks/configure-mariadb.yml)
        ```yaml
        - name: Make mariadb server file configuration
          template:
            src: server.cnf.j2
            dest: /etc/mysql/mariadb.cnf
          notify: restart mariadb server
          when: ( ansible_distribution_file_variety == "Debian" )
        ```
      - [update:](https://github.com/akihiro-o2k/cacti-enviroment/blob/develop/ansible/roles/db/tasks/configure-mariadb.yml)
        ```yaml
        - name: Make mariadb server file configuration
          template:
            src:  50-server.cnf.j2
            dest: /etc/mysql/mariadb.conf.d/50-server.cnf
          notify: restart mariadb server
          when: ansible_distribution == 'Ubuntu'
        ```
1. roles/db/tasks/initiate_database.yml
    - 変更の概要
      - 初期構築データベース意外にもデータ操作が必要となるデータベースがあったのでコード改修。
        - `sql_file_name`配列の変更->バッチファイル名を指定する配列から、DB名とバッチファイル名を記入する連想配列に変更。

    - code
      - [origin:](https://github.com/mahdi22/ansible-mariadb-install/blob/master/tasks/initiate_database.yml)
        ```yaml
        - name: Copy SQL script files
          copy:
            src: "{{ item }}"
            dest: /tmp/
          with_items: "{{ sql_file_name }}"
          when: import_sql_file
        
        - name: Import init script to database
          mysql_db:
            name: "{{ database }}"
            state: import
            target: /tmp/{{ item }}
            login_user: root
            login_password: "{{ mysql_root_password }}"
          when: 
            - database is defined and create_database
            - import_sql_file
        
        - name: Delete SQL script files
          file:
            path: /tmp/{{ item }}
            state: absent
          with_items: "{{ sql_file_name }}"
          when: import_sql_file
        ```
      - [update:](https://github.com/akihiro-o2k/cacti-enviroment/blob/develop/ansible/roles/db/tasks/initiate_database.yml)
        ```yaml
        - name: Copy SQL script files
          copy:
            src: "{{ item.file }}"
            dest: /tmp/
          with_items: "{{ sql_file_name }}"
          when: import_sql_file
        
        - name: Import init script to database
          mysql_db:
            name: "{{ item.db }}"
            state: import
            target: "/tmp/{{ item.file }}"
            login_user: root
            login_password: "{{ mysql_root_password }}"
          with_items: "{{ sql_file_name }}"
          when: 
            - database is defined and create_database
            - import_sql_file
        
        - name: Delete SQL script files
          file:
            path: "/tmp/{{ item.file }}"
            state: absent
          with_items: "{{ sql_file_name }}"
          when: "{{ import_sql_file }}"
        ```
      - 参考:連想配列`import_sql_file`はvar/common.ymlで下記の様に定義。
        ```yaml
        - sql_file_name:
          - { db: 'cactidb', file: '01_criate_cacti_tables.sql' }
          - { db: 'mysql', file: '02_insert_mysql_data_timezone.sql' }
          - { db: 'mysql ', file: '03_grant_select_parmission.sql' }
        ```  

