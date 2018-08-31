# docker-recpt1-pxw3pe

- PX-W3PEで動作するrecpt1をDockerコンテナ内でビルドします
- ホストOS側デバイス(/dev/asv5022[0-3])を利用して動作します
- なるべく出所が明らかなところからソースコードを取得しています
- 2018年の前半におこなわれたBSのトランスポンダ変更に対応しています

## 動作確認環境

```
CentOS release 6.10 (Final)
Docker version 1.7.1, build 786b29d
docker-compose version 1.5.2, build 7240ff3
```

ホストOS側でPX-W3PEのLinuxドライバを正しくインストールしてください。

## 使い方

git cloneしたディレクトリ名がコンテナ名の一部に使われるので適当な短い名前を推奨します。
```
mkdir /usr/local/projects
git clone https://github.com/yanbe/docker-recpt1-pxw3pe.git /usr/local/projects/recpt1
cd /usr/local/projects/recpt1
docker-compose build
docker-compose run --rm pxw3pe checksignal 101 # NHK BS1 (101ch)
```
