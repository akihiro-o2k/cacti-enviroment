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
    ```
### 独自改修箇所
- 対象ファイル:roles/db/vars/Ubuntu.yml
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

