# 商用環境独自エラー
​
## apt-add-repositoryコマンド実行エラー
- 原因:apt-add-repositoryコマンドがapt側に設定したproxy参照設定を読み込めない為、http接続が出来ていない。
  ```text
  # syntax
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  # Error message
  > Cannot add PPA: 'ppa:~ansible/ubuntu/ansible'.
  > ERROR: '~ansible' user or team does not exist.
  ```
- 解決方法:apt-add-repository ppa:ansible/ansibleで追加されるPGP-KEYと生成するapt参照先ファイルを手動追加。
  - (ネット上では`sudo -E`オプションで環境を引き継ぐ方式での解消事例が記載されているが、この方式では解決しなかった)
1. ppa:ansible/ansibleのPGPKEYの手動追加
    ```bash
    curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | sudo apt-key add
    ```
​
1. apt参照先ファイルの手動追加
  - `sudo vi /etc/apt/sources.list.d/ansible.list`
      ```text
      # Adde the Ansible sources.
      deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main
      deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu focal main
      ```
​
1. 上記コマンドの実施でエラー発生コマンドの実行結果と同じ振る舞いとなる為、後続コマンドを実行。
    ```bash
    sudo apt update
    sudo apt install ansible
    # 無事ansibleのインストール完了。
    ```
## 課題
- PHP/Mariadb等のインストールがansible上でapt-add-repositoryコマンドを実行している為、スタックする可能性あり。provisioningで動作検証を行い、同じ事象が発生するならばコマンドを書き換える必要あり。
​
- 参考情報:
  - https://askubuntu.com/questions/738727/installing-ansible-on-ubuntu
