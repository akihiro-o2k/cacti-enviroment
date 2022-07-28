# 見える化案件用Cactiサーバープロビジョニング／テスト方式設計書

## 概要

- 見える化案件において冗長構成かつ複数網に同一構成のサーバーを構築する要件の実現方式として、
  サーバープロビジョニング及び、構成のテストをスクリプトにて自動実行を行う。

### 設計へのインプットとなる要件及び、関連文書・仕様
  - お客様配布文書「(セキュリティ関連で現状は伏字XXX)」の求める仕様に準拠する。
  - 上記文書の要件に基づいて導入するサーバー及びミドルウェア、ソフトウェアは「技術アーキテクチャ標準細則(第17.0版)」及び、外部文書「(別表1)標準化技術リスト(製品サポート情報etc)_20220629」の要件に準拠する。

## 動作環境
- サーバーOS: Ubuntu 20.04.4 LTS
- サーバープロビジョニング方式
  - ansible [core 2.12.6]
    -  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
    - jinja version = 2.10.1
- サーバーテスト方式
  - serverspec (2.42.0)
    - ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]
    - rake, version 13.0.6
- 特記事項
  - 動作環境(サーバープロビジョニング及び、サーバーテスト方式)の各種アプリケーションプラットフォームは要件を充足する上で便宜的に構築する副産物である為、「設計へのインプットとなる要件及び関連文書・仕様」で求められる技術標準化リストのバージョンを考慮せず、OS安定版として提供するバージョンの物を使用する。
  - 上記のサーバープロビジョニング／テスト動作環境を便宜的に「管理用VM」と定義し当該文書上に記載する。

### ミドルウェア
  - 選定基準
    - Cactiの動作に必要となるミドルウェアを「設計へのインプットとなる関連文書・仕様」で定義の文書に照らし合わせ、標準利用可能なっているミドルウェア・バージョンを選定する。
  - 必須ミドルウェア(バージョン)
    1. Apache(2.4.x)
    1. php(8.1)
    1. mariadb(10.8)
  - その他、上記パッケージ導入に付随して導入するパッケージ[^1]
    - traceroute
    - build-essential
    - curl
    - wget
    - ppa:ondrej/php
    - oftware-properties-common
    - dirmngr
    - snmp
    - snmpd
    - rrdtool
    - libmysql++-dev
    - libsnmp-dev
    - help2man
    - dos2unix
    - autoconf
    - dh-autoreconf
    - libssl-dev
    - librrds-perl

## サーバー構成
### 基本設計
  - 「構築XXXXXXXXXX」６頁の「基盤構成」に記載の要件に準拠する。
      ```bash
      vFW
      │
      vLB
      ├── 管理用VM:(ansible/serverspecの実行ホスト)
      ├── NPM01
      ├── NPM02
      ├── (状況によりVIPを設定(仕様未確定))
      ├── NPMDB01
      ├── NPMDM02
      ├── (状況によりVIP,HAクラスター導入(仕様未確定))
      ├── cacti01
      ├── cacti02
      └── (状況によりVIPを設定(仕様未確定))
      ```

### 基本構築手順
- 各サーバー毎にスクリプトでプロビジョニング／テストを実行する為の最低限の環境を手動で構築する。

#### 管理用VM
  1. Ubuntu20.04のインストール[^2]
  1. ホスト名設定[^2]
  1. sshserverインストール[^2]
  1. 初期ユーザーにdevelopユーザー追加[^3]
  1. 固定IP設定ファイル編集
      ```bash
      # 既存の設定ファイル名の末尾にdisabledを付けて無効化しつつバックアップ
      sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.disabled
      # 新規設定ファイルを01として記述
      sudo cp -p /etc/netplan/00-installer-config.yaml.disabled /etc/netplan/01-installer-config.yaml
      ```
      ```yaml
      # /etc/netplan/01-installer-config.yamlの記入例
      network:
        ethernets:
          ens33:
            addresses: [172.16.234.130/24]
            gateway4: 172.16.234.2
            nameservers:
              addresses: [172.16.234.2]
              search: []
        version: 2
      ```
  1. netplanコマンドの実行(固定IP設定の適用)
      ```bash
      sudo netplan try --timeout 5
      # sudo netplan apply
      ```
  1. cacti01/02への名前解決設定(/etc/hostsで名前解決)
     ```bash
     # ipはお客様指定の値
     XXX.XXX.XXX.XX1  cacti01
     XXX.XXX.XXX.XX2  cacti02
     ```
  1. SSH公開鍵作成(ED25519鍵)
      ```bash
      # 参考-> https://linuxfan.info/ssh-ed25519
      ssh-keygen -t ed25519
      ```
  1. ssh-copy-idコマンドによるcacti01/02への公開鍵認証設定の実施。
      ```bash
        ssh-copy-id develop@[remote_host]
      ```
  1. ssh公開鍵認証設定
      ```bash
      # ~develop/.ssh/configの記入例
      Host cacti01
        HostName XXX.XXX.XXX.XXX
        User develop
        Port 22
        IdentityFile ~/.ssh/id_ed25519
      ```
  1. サーバープロビジョニングツール:ansibleインストール
      ```bash
      sudo apt update -y
      sudo apt install -y software-properties-common
      sudo apt-add-repository --yes --update ppa:ansible/ansible
      sudo apt install -y ansible
      # インストール済み確認コマンド
      ansible --version
      #=>ansible [core 2.12.6] 以下、省略
      # インストール処理中にYes/No等対話形式入力に対応する為のモジュール追加
      sudo apt install python3-pip
      sudo pip install pexpect
      ```
  1. サーバー構成テストツール：sarverspecインストール
      ```bash
      sudo apt install ruby ruby-dev
      # rubyパッケージ管理システムgemは、環境変数http_proxyを参照してproxyの適用を判断する。
      sudo gem install serverspec
      # 確認コマンド
      gem list serverspec
      #=> serverspec (2.42.0)
      sudo gem install rake
      # 確認コマンド
      rake -V
      # 依存関係パッケージのインストール(公開鍵認証->ed25519対応の為のパッケージ)
      sudo gem install highline ed25519 bcrypt_pbkdf
      ```
#### cacti01/02(共通)
  1. Ubuntu20.04のインストール[^2]
  1. ホスト名設定[^2]
  1. sshserverインストール[^2]
  1. 初期ユーザーにdevelopユーザー追加[^3]
  1. 固定IP設定ファイル編集
      - 管理用VM側の手順を参照。
  1. netplanコマンドの実行(固定IP設定の適用)
      - 管理用VM側の手順を参照。


### サーバープロビジョニング／テスト実行方法

- 前提条件
  1. githubより当該スクリプトをダンロードする(暫定で個人のプライベートリポジトリに格納)
      - `git@github.com:akihiro-o2k/cacti-enviroment.git cacti_enviroment`
  1. 取得したディレクトリに遷移
      - `cd cacti_enviroment`
  1. 開発中はdevelopブランチを使用している為、合わせて取得（商用環境においては全てmainブランチにマージして適用する）
      - `git checkout -b develop remotes/origin/develop`
      - `git checkout develop`
  1. スクリプト実行対象のサーバーにcacti01,cacti02でそれぞれ名前解決できるように/etc/hostsを編集。
  1. スクリプト実行対象のサーバーに規定のスクリプト実行ユーザー`develop`で/etc/hostsで定義したホスト名にて、ssh公開鍵認証(ED25519鍵)でパスワード認証無しの接続が出来るように設定。

  1. 環境変数の設定(必須)
      - 下記の環境変数コマンドをdevelopユーザーの.bashrcに追記して適用する。
        ```bash
        export SUDO_PASSWD=[cacti01,02で共通するdevlopユーザーのパスワード]
        export ENVIROMENT=development
        export SSH_KEY=/home/develop/.ssh/id_ed25519
        # 設定追記後はsource ~develop/.bashrc等で設定を反映する必要あり。
        ```
- サーバープロビジョニングの実施
  - 実施の概要(TestFrist方式)
    - サーバープロビジョニングは先行してserverspecを実行して、現在の状態がテストスクリプトで期待する設定になっていないことを確認(テストがエラーになることの確認)の後にansibleを実行してサーバーの構築を実施する。その後再度serverspecを実行して前回テストでエラーとなっている箇所が改善された事をもって設定の完了とする。
  - ディレクトリ構造
    - 以下にcacti_enviromentディレクトリ構造及び、格納ファイルのポリシーを表す。

        ```bash
        # 暫定で個人プライベートリポジトリに格納。
        # https://github.com/akihiro-o2k/cacti-enviroment
        cacti_enviroment
        │
        ├── ansible               [ansible実行時のルートディレクトリ]
        │   ├── ansible.cfg         (ansible全体設定)
        │   ├── deploy.yml          (プロビジョニングファイル)
        │   ├── development.ini     (開発環境イベントリ)
        │   ├── staging.ini         (検証環境イベントリ)
        │   ├── production.ini      (商用環境イベントリ)
        │   ├── roles               (プロビジョニング実設定格納ディレクトリ)
        │   │   ├── httpd           (httpd設定)
        │   │   └── linux-base      (os設定)
        │   │   └── db              (mariadb設定)
        │   └── vars                (変数定義ディレクトリ)
        │       ├── common.yml      (共有変数定義ファイル)
        │       ├── development.yml (開発環境の変数)
        │       └── staging.yml     (検証環境の変数)
        │       └── production.yml  (商用環境の変数)
        ├── doc                     (各種ドキュメント格納ディレクトリ)
        │   └── documents
        ├── README.md               (github見出しファイル)
        └── serverspec            [serverspec実行時のルートディレクトリ]
            ├── Rakefile            (serverspec全体設定)
            ├── lib                 (独自ライブラリ格納ディレクトリ)
            └── spec                (テストコード格納ディレクトリ)
                ├── db              (mariadbテスト)
                ├── httpd           (httpdテスト)
                ├── linux-base      (osテスト)
                ├── spec_helper.rb  (テストコード共通設定)
                └── vars            (../../ansible/vars/へのシンボリックリンク)
        ```
  - 手順
    1. serverspecでの事前設定状態確認
        - serverspecを実行し、現在のCacti01/02の状態を確認する。
          ```bash
          # serverspecルートディレクトリに遷移
          cd serverspec
          # serverspec実行コマンドのsyntax
          # rake serverspec:[target_host]
          # -> [target_host]は/etc/hostsと~develop/.ssh/configで事前設定。
          rake serverspec:cacti01
          ```
        - 期待するserverspec戻り値:テスト内容をクリア出来ない事を表すRed表示。
          ![参考:green表示](image/serverspec_red.png)
    1. ansibleでのサーバー設定の実施
        - ansible実行により、スクリプトに定義されているサーバー設定を実施する。
          ```bash
          # serverspecルートディレクトリに遷移
          cd ansible
          # serverspecの実行コマンドsyntax
          # ansible-playbook -i [イベントリファイル名] -l [実行ロール名] [プロビジョニングファイル名] [オプション]
          # 尚、イベントリファイル名は実行環境をserverspecと共通化する為にサーバーENV化を推奨。
          # ロールは現在all,cacit[01|02]を想定。
          # ->Option： -C(Dry Runの実行),-v(詳細表示。vの数でより詳細情報を表示) 
          ansible-playbook -i ${ENVIROMENT}.ini -l cacti01 deploy.yml -vvv
          ```
    1. serverspecの再実行(設定完了を確認)
        - serverspecを実行し、ansibleスクリプト実行後のCacti01/02の状態を確認する。
          ```bash
          # serverspecルートディレクトリに遷移
          cd serverspec
          # serverspec実行コマンドのsyntax
          # rake serverspec:[target_host]
          # -> [target_host]は/etc/hostsと~develop/.ssh/configで事前設定。
          rake serverspec:cacti01
          ```
        - 期待するserverspec戻り値:テスト内容をクリアした事を表すGreen表示。
          ![参考:green表示](image/serverspec_green.png)

#### 補足

[^1]: OS標準バージョンと異なるミドルウェアを導入する為に必要となるaptリポジトリの追加及び、cacti導入の為の依存関係にあるパッケージを追加。
[^2]: インストール時の対話形式入力値。別紙「Ubuntu20インストール手順」を参照。
[^3]: サーバープロビジョニング／テストを実行する為のテンポラリユーザー。セキュリティ観点で最終的に削除を実施。

