## 前提
- flutterSDKインストール

## flutter構築
1. このプロジェクトをcloneする
1. 下記を実行する
```
cd front
flutter pub get
```
2. https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios
のステップ２までを実行する

3. flutter runで起動する

## cloud functions構築
1. cloud_functions/functions/.env.sampleをコピーして、cloud_functions/functions/.envを作成し、.envの環境変数の値を入力する

2. cloud_functions/.firebaserc.exampleをコピーして、cloud_functions/.firebasercにfirebaseのproject idを入力する

2. firebase loginで認証する

2. 下記コマンドを実行して、関数をデプロイする
```sh
cd cloud_functions/functions
npm install
npm run build
npm run deploy
```

## AI agent構築
こちらのリポジトリのREADMEで構築
https://github.com/croro613/help_man_ai_agent
