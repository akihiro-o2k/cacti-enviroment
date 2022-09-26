# 事象: ppa:ansible/ansibleリポジトリが追加できない

- 原因:apt-add-repositoryコマンドがapt側に設定したproxy参照設定を読み込めない為、http接続が出来ていない。
- 解決方法:apt-add-repository ppa:ansible/ansibleで追加されるGPG-KEYと生成するapt参照先ファイルを手動追加。

- ppa:ansible/ansibleのGPGKEYの手動追加

  ```bash
  curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367" | sudo apt-key add
  ```

- apt参照先ファイルの手動追加
  - `sudo vi /etc/apt/sources.list.d/ansible.list`
      ```text
      # Adde the Ansible sources.
      echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | sudo tee -a /etc/apt/sources.list.d/ansible.list
      echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" | sudo tee -a /etc/apt/sources.list.d/ansible.list
      ```

- 上記コマンドの実施でppa:ansible/ansibleが追加されたのと同じ振る舞いとなる為、後続コマンドを実行。
    ```bash
    sudo apt update
    sudo apt install ansible
    ```

- 参考情報:
  - https://askubuntu.com/questions/738727/installing-ansible-on-ubuntu
