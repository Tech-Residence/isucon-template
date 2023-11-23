# isucon-template

ISUCON用のテンプレートリポジトリ
試合毎にcloneして調整して使用する。

## Requirements

- docker
- docker-compose >= v3.0

## Playbooks

用意されているplaybook一覧

- install_packages.yaml: サーバーに必要なパッケージをインストールするplaybook。最初に一度だけ実行する
- prepare_bench.yaml: ベンチマークテスト前に実行するplaybook。contestsのコピー、ビルド、各種アプリ・ミドルウェアの再起動、ログローテートなどを行う
- analyze.yaml: ベンチマークの結果を解析するplaybook。

## Usage

### 初期設定

#### インベントリファイルの作成

サーバー情報を`playbooks/inventory.ini`に記入する。
最低限必要な情報は `ansible_host` と `ansible_user` の2つ。

サーバー情報を書き換えたら接続確認は以下のコマンドで行う。

```
make ping
```

#### パッケージインストール

必要なパッケージを全サーバーにインストールする。

```
make install-packages-all
```

> [!NOTE]
> 個別にインストールしたいときは、`make install-packages-N` でN番目のサーバのみにパッケージをインストールすることもできる。

> [!NOTE]
> 完了まで数分かかるが、待たずに次の作業を進めることができる。

#### コンテンツのコピー

必要なファイルをサーバーから`contents`ディレクトリにコピーする。

> [!NOTE]
> - 大会ごとに必要なファイルは異なる。
> - `/home`, `/etc` 以下すべてをrsyncしてくると、ファイル数もサイズも大きすぎでgit管理できなくなるため必要なファイルだけ選ぶ
> - `/etc`　以下はシンボリックリンクが多いので注意。シンボリックリンクをrsyncしてきても編集はできない。
>
> 以下のファイルは対象となることが多いので必ずチェックする
>
> - アプリケーションファイル
>   - `/home/isucon` などに配置されることが多い
> - nginxの設定ファル
>   - `/etc/nginx/nginx.conf` に配置されることが多い。見つからないときは、(`nginx -V`コマンドで確認できる。)
>   - `/etc/nginx/nginx.conf` のなかで別ファイルをincludeしていることも多いのでそれらのファイルもチェックする。記述量次第では`nginx.conf`にすべてまとめてしまうといいかもしれない。
> - mysqlの設定ファイル
>   - `/etc/my.cnf` に配置されることが多い。見つからないときは、(`mysqld --verbose --help | grep -A 1 "Default options"` コマンドで確認できる。)
> - systemdのserviceファイル
>   - `/etc/systemd/system` 以下に配置されることが多い。

#### prepare_bench.yamlの修正

- 各種ファイルパス・パーミッション
- ビルドコマンド
- systemdのservice名

などを変更する。

### 大会中の使い方

#### ベンチマークの準備

次のコマンドでベンチマーク前に必要な処理が実行される。

```
make prepare-bench-N
```
"N"は実行対象のサーバー番号 (1, 2, 3のいずれか)

実行される処理は以下の通り、

1. `contents`以下のファイルをサーバーの適切なパスにコピー
2. Goコードのビルド
3. SQLファイルの実行
4. Logのローテート
5. systemdサービスのリスタート

#### ログの解析

ベンチマーク実行後にログを解析して結果をサーバーからローカルの`result`ディレクトリにコピーする。

```
make analyze-logs-N
```
