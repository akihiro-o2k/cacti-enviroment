# Ubuntu20で動作検証

## 基本設定(手動設定)
- ユーザー:
  - 初期ユーザー:
    - ユーザー名: visualize
    - パスワード: visualize
  - OS管理ユーザー:
    - ユーザー名: root
    - パスワード: Visualise0033#

- ホスト名: cacti

### 初期設定(サーバー設定用スクリプト動作環境の準備)

- サーバープロビジョニングツール:ansibleインストール
    ```bash
    sudo apt update -y
    sudo apt install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
    ```

- サーバー構成確認ツール：sarverspecインストール
    ```bash
    sudo apt install ruby
    sudo gem install serverspec
    sudo gem install rake
    ```
