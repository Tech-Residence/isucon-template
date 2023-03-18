# isucon-template

ISUCON用のテンプレートリポジトリ
試合毎にcloneして調整して使用する。

## Requirements

- docker
- docker-compose >= v3.0

##　Playbooks

用意されているplaybook一覧

- install_packages.yaml: サーバーに必要なパッケージをインストールするplaybook。最初に一度だけ実行する
- prepare_bench.yaml: ベンチマークテスト前に実行するplaybook。contestsのコピー、ビルド、各種アプリ・ミドルウェアの再起動、ログローテートなどを行う
- analyze.yaml: ベンチマークの結果を解析するplaybook。

## Usage

### 事前準備

#### 大会用リポジトリの用意

このリポジトリをフォークして試合専用のリポジトリを作成しておく。フォーク先のリポジトリは**必ずprivateリポジトリにする**よう注意。

#### サーバー接続用の秘密鍵の設定

サーバーに接続するための鍵を大会参加登録時に登録したと思うので、その鍵を設定しておく。
プロジェクト直下に`.env`ファイルを作成して`PRIVATE_KEY`変数の値として記載する。

注意点:
- `$HOME/.ssh`以下にあるファイルしか使えない
- フルパスではなくファイル名のみ記載する
- ISUCON本番は参加登録時に申請した鍵

サンプル

```
PRIVATE_KEY="id_ed25519"
```

#### コンテナビルド

ansibleの実行もGoコードのビルドも基本的にはすべてコンテナ上で行う。そのコンテナをビルドしておく。

```
make container-build
```

### 大会当日の使い方

下記の順番で実行する。

#### インベントリファイルの作成

サーバー情報を`playbooks/inventory.ini`に記入してgit pushする。

#### パッケージインストール

必要なパッケージをサーバーにインストールする。

```
make install-packages
```

完了まで数分かかるが、待たずに次の作業を進めることができる。

#### コンテンツのコピー

必要なファイルをサーバーから`contents`ディレクトリにコピーする。

注意点:

- 大会ごとに必要なファイルは異なる。
- `/home`, `/etc` 以下すべてをrsyncしてくると、ファイル数もサイズも大きすぎでgit管理できなくなるため必要なファイルだけ選ぶ
- `/etc`　以下はシンボリックリンクが多いので注意。シンボリックリンクをrsyncしてきても編集はできない。

以下のファイルは対象となることが多いので必ずチェックする

- アプリケーションファイル
  - `/home/isucon` などに配置されることが多い
- nginxの設定ファル
  - `/etc/nginx/nginx.conf` に配置されることが多い。見つからないときは、(`nginx -V`コマンドで確認できる。)
  - `/etc/nginx/nginx.conf` のなかで別ファイルをincludeしていることも多いのでそれらのファイルもチェックする。記述量次第では`nginx.conf`にすべてまとめてしまうといいかもしれない。
- mysqlの設定ファイル
  - `/etc/my.cnf` に配置されることが多い。見つからないときは、(`mysqld --verbose --help | grep -A 1 "Default options"` コマンドで確認できる。)
- systemdのserviceファイル
  - `/etc/systemd/system` 以下に配置されることが多い。

(例)
```
mkdir contents
rsync -avz $USER@$IP:/home/isucon/<必要なディレクトリ> ./contents
rsync -av $USER@$IP:/etc/nginx/nginx.conf ./contents
rsync -av $USER@$IP:/etc/my.cnf ./contents
rsync -av $USER@$IP:/etc/systemd/system/<アプリケーションのserviceファイル> ./contents
...
```

#### prepare_bench.yamlの修正

(後で記載する)
