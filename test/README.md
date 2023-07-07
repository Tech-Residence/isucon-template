# テスト

## Requirements

- Docker
- docker-compose
- multipass
- jq
- make
- ssh-keygen

## playbookの動作確認方法

### 動作確認用VMの起動

playbookの実行対象とするテスト用のサーバーVMをmultipassで起動する。
以下のコマンドですべてのセットアップとサーバーVMの起動が完了する。

```
make start-test-server
```

内部では以下の操作が行われる。

1. VM接続用のSSH鍵ペアの作成　(`tmp/id_ed25519`, `tmp/id_ed25519.pub`)
2. VMの設定ファイルの作成（`tmp/cloud-init.yaml`）
3. test用のinventoryファイルの作成（`tmp/inventory.ini`）
4. multipass VMの作成 (VM名 `isucon-template-test`)

### 接続確認

サーバーが正常に起動して設定ファイルも正しく生成されていることを確認するために、次のコマンドで接続確認テストをする。

```
make ping-test-server
docker-compose run ansible-runner ansible -m ping all -i /home/ubuntu/tmp/inventory.ini --private-key="/home/ubuntu/tmp/id_ed25519"
server-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### 動作確認用VMの停止

```
make destroy-test-server
```


### Tips

#### VMに直接ログインしたい場合

```
multipass shell isucon-template-test
```
