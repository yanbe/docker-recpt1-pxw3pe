# docker-recpt1-pxw3pe

- PX-W3PEで動作するrecpt1をDocker上でビルドし、ホストOSのデバイス(/dev/asv5022[0-3])を利用して動作します
- なるべく出所が明らかなソースコードを取得しています
- 2018年の前半に行われたBSのトランスポンダ変更に対応しています

## 動作確認環境

```
CentOS release 6.10 (Final)
Docker version 1.7.1, build 786b29d
docker-compose version 1.5.2, build 7240ff3
```

## 使い方

```
docker-compose build
docker-compose run pxw3pe checksignal 101 # NHK BS1 (101ch)
``
