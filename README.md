# cloud-formation-stack-lambda-log

私はcfnで作ったLambdaのログをCLIからサクッと見たいのだよ。
いちいちコンソール開いて、Lambdaのリソース名が分からなくてCloudFormationのテンプレートを開いて、リソース名を確認して、コンソールに戻って、ログを見るのは面倒くさいのだよ。

ということで、さくっとログ見るために作ったscript。

## 依存関係

下記がインストールされている必要があります

- fzf
- aws-cli （v2以降）

```sh
# mac 向けインストール手順
brew install fzf
brew install awscli
```

## インストール方法

このディレクトリで叩いてね
```
$ sudo ln -s $PWD/cloud-formation-stack-lambda-log.sh /usr/local/bin/tail-cfn-lambda
$ source ~/.bashrc
```

## アンインストール方法

下記のファイルを削除する。

`/usr/local/bin/cloud-formation-stack-lambda-log`

## 使い方

```
$ cloud-formation-stack-lambda-log
```

