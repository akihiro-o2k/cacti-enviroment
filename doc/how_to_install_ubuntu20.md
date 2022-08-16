# Ubuntu20 インストール手順

### 文書の概要
- ansibleによるCacti環境プロビジョニングを行う為の前段として以下の設定を行う必要がある。
1. Ubuntu20.04のインストール
  1. ホスト名設定
  1. sshserverインストール
  1. 初期ユーザーにdevelopユーザー追加
1. 固定IP設定ファイル編集

### VMwareFusionでのUbuntuインストール初期設定

- TODO：開発環境のVMWareFusionにISOイメージよりUbuntu20を追加する方式で仮記載するが、商用環境はSDPFで構築となる為、検証と異なる部分は文書書き換えとスナップショット再取得が必要となる。

1. VMWareFusionメニューよりファイル->新規を選択し、表示されるウィンドウの「ディスクまたはイメージからインストール」の箇所にインストール対象となるUbuntu20のISOイメージをドラッグする。
    - UbuntuのISOimageファイルは[ubuntu-20.04.4-live-server-amd64.iso](https://releases.ubuntu.com/20.04/ubuntu-20.04.4-live-server-amd64.iso)を使用。
![image01](doc/images/u20_install/01.png) 
1. ドラッグしたイメージファイルを選択して「続ける」ボタンを押下。
![image02](doc/images/u20_install/02.png) 
1. 「Linux簡易インストール画面」が表示されたら以下の値を入力して「続ける」ボタンを押下。
    - ディスプレイ名: cacti0X
    - アカウント名: develop
    - パスワード： develop
    - パスワードの確認: develop
      - 補足:developユーザーは初期構築作業の最後で削除を行う為、例外的に当該文書にパスワードが記載されていてもセキュリティー上の問題は生じない。
![image03](doc/images/u20_install/03.png) 

1. 「終了」画面では各種設定値に問題がない事を確認し、「終了」ボタンを押下する。
![image04](doc/images/u20_install/04.png) 
  - TODO:CPU／メモリ／ディスクサイズの試験項目をserverspecで作成する(パラメータはvars/enviromentファイルに切り出す)。
1. 名前の入力欄には「ディスプレイ名」と同じ値を定義し、タグ欄は「Ubuntu20」、場所は初期値のままで「保存」ボタンを押下。
![image05](doc/images/u20_install/05.png) 

### Ubuntu20.04インストール
1. Select your langage.ではSDPFの規定のキーボードである「English」に矢印キーでカーソルを合わせて[Return
]キーを押下。
![image06](doc/images/u20_install/06.png) 
1. Installer update available画面でマイナーバージョンアップのインストーラが出ていても、カーソルは「Continue without updating」を選択して[Return]キーを押下。
    - 理由：画像でUpdateが提供されている20.07をインストールすると、業務要件として追加するアプリケーションが未対応で動作しない可能性がある為、20.04版をインストールする必要がある。
![image07](doc/images/u20_install/07.png)
1. Keybord configuration の選択値は規定の値(Layout:English(US), Variant: English(US))のまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image08](doc/images/u20_install/08.png)
1. Network connections もOS起動後にSSHで設定変更を行う為、DHCP割り当ての規定値のまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image09](doc/images/u20_install/09.png)
1. Configure proxy 検証環境ではproxyの利用がない為、規定値(空白)のまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image10](doc/images/u20_install/10.png)
1. Configure Ubuntu archive mirror 規定値(https:jp.archive.ubuntu.com/ubuntu)のまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image11](doc/images/u20_install/11.png)
1. Guided storage configuration 規定値のままのまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image12](doc/images/u20_install/12.png)
1. Storage configuretion ディスク割り当て状態に問題なければ、「Done」にカーソルを合わせて[Return]キーを押下。
![image13](doc/images/u20_install/13.png)
1. Profile setup 以下の値を入力の後に「Done」にカーソルを合わせて[Return]キーを押下。
    - your name: develop
    - your server's name: [ディスプレイ名と同じ値を入力]
    - Pick a username: develop
    - Choose a password: develop
    - Confirm your password: develop
      - 補足:developユーザーは初期構築作業の最後で削除を行う為、例外的に当該文書にパスワードが記載されていてもセキュリティー上の問題は生じない。

![image14](doc/images/u20_install/14.png)

1. Enable Ubuntu Advantage 設定対象外のため、規定値(空白)のまま、「Done」にカーソルを合わせて[Return]キーを押下。
![image15](doc/images/u20_install/15.png)
1. SSH Setup はSSHを有効化したいので「Install OpenSSH server」にチェックし、Import SSH identityはNoの状態で 「Done」にカーソルを合わせて[Return]キーを押下。
![image16](doc/images/u20_install/16.png)
1. Featured Server Snapsでは全て空白のまま「Done」にカーソルを合わせて[Return]キーを押下。
![image17](doc/images/u20_install/17.png)
1. インストールシーケンスが走るが選択項目に「Cancel Update and reboot」が表示されたら初期Install処理は完了しているので、カーソルを合わせて[Return]キーを押下。
![image18](doc/images/u20_install/18.png)

