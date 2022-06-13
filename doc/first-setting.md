# Ubuntu20で動作検証

## 基本設定(手動設定)
- サーバーホスト名:cacti
- OSユーザー:
  - 初期ユーザー:
    - ユーザー名: visualize
    - パスワード: v********
  - OS管理ユーザー:
    - ユーザー名: root
    - パスワード: V**********

- Network-interface
　- 初期設定
    ```bash
    # 既存の設定ファイル名の末尾にdisabledを付けて無効化しつつバックアップ
    sudo cp -p /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.disabled
    # 新規設定ファイルを01として記述
    sudo cp -p /etc/netplan/00-installer-config.yaml.disabled /etc/netplan/01-installer-config.yaml
    # 以下、VMware環境でDHCPでのIP/GW/DNS設定情報を取得に使用したコマンドの備忘
    # ip確認
    #->ip addr
    # dns確認コマンド
    #-> sudo cat /run/systemd/resolve/resolv.conf
    # GW確認コマンド(net-toolsが必要->sudo apt install net-tools)
    #-> route -n
    # 別ネットワークとの疎通用にNICを追加した場合、そちらのNICもあわせて設定
    sudo netplan try --timeout 10
    ```
  - 以下、01-installer-config.yaml設定例
    ```yaml
    network:
      ethernets:
        ens33:
          addresses: [172.16.234.130/24]
          gateway4: 172.16.234.2
          nameservers:
            addresses: [172.16.234.2]
            search: []
            #optional: true
      version: 2
    ```
  - 以下設定の反映コマンド
    ```bash
    # netplan applyでも実行可能だが、tryコマンドはsyntaxチェックを行ってくれて、
    # 問題がある場合、ERROR表記となり、--timeout 10オプションで10秒間Enterキーが押下されなければ反映は取りやめて以前の設定に戻してくれる。
    sudo netplan try --timeout 10
    ```


  <!-- このブロックは別途ansibleとsaverspecに切り出す予定だが方法論だけここに定義 --->
  - NTP参照設定
    - NTPクライアントの動作確認
      ```bash
      # Ubuntu規定のNTPD→deamon systemd-timesyncdの動作確認
      sudo systemctl status systemd-timesyncd
      # プリインストールで定義されているNTPD参照先を確認
      sudo timedatectl timesync-status | grep Server
      #=>Server: 91.189.94.4 (ntp.ubuntu.com) 
      ```
    - NTP参照先サーバーをローカルのNTPDに変更(事前に通信要件に含まれている事を確認)
      ```bash
      # backupの実行
      sudo cp -p /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.backup
      # 最終行にパラメータ追加(参照先NTPDを追記)
      sudo echo NTP=[append.local.ntpd.ip-address] >> /etc/systemd/timesyncd.conf
      # 設定追記状態確認
      cat /etc/systemd/timesyncd.conf | grep [append.local.ntpd.ip-address]
      # systemd-timesyncdの再起動で設定反映
      sudo systemctl restart systemd-timesyncd
      # 再起動後に追記したNTPDサーバーのIPアドレスがtimesyncdに反映されている事を確認。
      sudo timedatectl timesync-status | grep Server
      #=>Server: append.local.ntpd.ip-address
      ```

    - タイムゾーン変更(要否は別途相談)
      - タイムゾーン設定内容確認コマンド
        ```bash
        timedatectl | grep "Time zone"
        # UTCのケース
        # Time zone: Etc/UTC (UTC, +0000)
        # JST設定のケース
        # Time zone: Etc/UTC (UTC, +0000)
        ```
      - タイムゾーン設定コマンド
        ```bash
        sudo timedatectl set-timezone Asia/Tokyo
        ```

  <!-- 当該ブロックのexport処理はまとめてシェルスクリプト化して/etc/profile.d配下に保存し、OSログイン時に実行されるシェルにする -->
  - proxy設定(商用環境でAPT等を実行する為に必要)
      ```bash
      #  proxyのアドレス／ポート及び、接続に使用するユーザー情報をENVに登録。
      # 以下、proxy関連パラメータを変数として定義。構築段階では
      export proxy_user=xxxxx
      export proxy_user_pass=yyyyy
      export proxy_server=hoge.fuga.com
      export proxy_port=50080
      
      # 以下、proxyの実態設定値()
      export http_proxy="http://${proxy_user}:${proxy_user_pass}@${proxy_server}:${proxy_port}"
      export https_proxy=$http_proxy
      export ftp_proxy=$http_proxy
      # 以下、pipがproxyを参照する際に使用する変数(NET上の調査では大文字だった為、保険で登録)
      export HTTP_PROXY=$http_proxy
      export HTTPS_PROXY=$http_proxy
      export FTP_PROXY=$http_proxy
      
      # 以下、Ubuntuパッケージ管理システムaptにプロキシ設定を適用する
      if [ -f /etc/apt/apt.conf ]; then
        sudo rm -f /etc/apt/apt.conf
        sudo touch /etc/apt/apt.conf
      fi
      echo "Acquire::http::proxy ¥"http://${proxy_user}:${proxy_user_pass}@${proxy_server}:${proxy_port}/¥";" >> /etc/apt/apt.conf 
      echo "Acquire::https::proxy ¥"http://${proxy_user}:${proxy_user_pass}@${proxy_server}:${proxy_port}/¥";" >> /etc/apt/apt.conf 
      echo "Acquire::ftp::proxy ¥"http://${proxy_user}:${proxy_user_pass}@${proxy_server}:${proxy_port}/¥";" >> /etc/apt/apt.conf 

      # wget用の設定
      echo http_proxy=¥"$http_proxy/¥" >> /etc/wgetrc
      echo https_proxy=¥"$http_proxy/¥" >> /etc/wgetrc
      echo ftp_proxy=¥"$http_proxy/¥" >> /etc/wgetrc
      ```

### 初期設定(サーバー設定用スクリプト動作環境の準備)

- サーバープロビジョニングツール:ansibleインストール
    ```bash
    sudo apt update -y
    sudo apt install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
    # インストール済み確認コマンド
    ansible --version
    #=>ansible [core 2.12.6] 以下、省略
    ```

- サーバー構成確認ツール：sarverspecインストール
    ```bash
    sudo apt install ruby
    # rubyパッケージ管理システムgemは、環境変数http_proxyを参照してproxyの適用を判断する。
    sudo gem install serverspec
    # 確認コマンド
    gem list serverspec
    #=> serverspec (2.42.0)
    sudo gem install rake
    # 確認コマンド
    rake -V
    #=>rake, version 13.0.6
    ```

- git
  ```bash
  # インストール状態確認
  git --version | grep git || sudo apt-get install git
  #=> git version 2.25.1
  # インストールされていない場合は下記コマンドを実行
  sudo apt-get install git
  ```

