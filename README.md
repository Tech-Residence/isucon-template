# isucon-template

ISUCON用のテンプレートリポジトリ
試合毎にcloneして調整する。

## Requirements

- docker
- docker-compose >= v3.0
- multipass (for development)

## 最初にやること

### １. `.env`の作成

`.env`ファイルを作成して次の２つの変数を記載する。

- `PROJECT_NAME`: プロジェクト名 (ビルドされるコンテナVMのprefixになる)
- `PRIVATE_KEY`: サーバーへのSSH接続に使う秘密鍵　（`$HOME/.ssh`以下にあるファイルしか使えない。フルパスではなくファイル名のみ。）
  - ISUCON本番は参加登録時に申請した鍵
  - mockサーバーの接続に使う鍵は`mock/cloud-init.yaml`で登録されている公開鍵に対応する秘密鍵

サンプル
```
PROJECT_NAME=isucon13-qualify"
PRIVATE_KEY="id_ed25519"
```

### 2. コンテナビルド

ansibleの実行もGoコードのビルドも基本的にはすべてコンテナ上で行う。そのコンテナをビルドする。

```
make container-build
```

## Usage


### ISUCONの本番サーバーの初期セットアップ方法

全サーバーのセットアップ

```
make server-setup
```

### ベンチマークを回す準備

- Goのビルド
- ローカルファイルをサーバーへコピー
- ログのローテート

などを行う

```
make prepare-bench-1
make prepare-bench-2
make prepare-bench-3
```

末尾の数字を変えて対象サーバーを切り替える


## Development

### モックサーバーを使ったplaybookの開発方法

playbookを開発するときはLinuxのVMサーバーをローカルにたててそこに対してplaybookを流してデバッグをすると便利。以下の流れで開発をする。

#### 1. モックサーバーの起動

モックサーバーが存在しない場合は新規作成、停止中の場合は再起動、起動中の場合は何もしない。


```
make mock-start
```

#### 2. モックサーバーへの接続確認

```
make mock-ping
```

#### 3. リンターにかける

実際にplaybookをサーバーに流す前に文法ミスなどがないか確認する

```
make ansible-lint
```

#### 4. setup.yamlプレイブックを流す

```
make mock-ansible-playbook-setup
```

#### 5. モックサーバーの停止

```
make mock-stop
```

#### 6. モックサーバーの削除

```
make mock-destroy
```
