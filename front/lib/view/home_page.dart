import 'dart:math'; // ランダム値生成に使用

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:plan_assistant/cloud_functions_client.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool isListening = false;
  String transcript = "";
  String responseText = ""; // ここにサーバーからのHTMLを入れる

  // セッションIDをstateで管理
  String sessionId = "";

  @override
  void initState() {
    super.initState();
    // ページ到着時にランダムな値で初期化
    final random = Random();
    sessionId = random.nextInt(1000000).toString();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      // 音声認識停止
      await _speechToText.stop();
      setState(() {
        isListening = false;
      });

      // 音声認識で得た transcript を Cloud Functions に送る
      if (transcript.isNotEmpty) {
        print("Sending message: $transcript");
        try {
          final resultMessage = await CloudFunctionsClient().sendMessage(
            text: transcript,
            sessionId: sessionId, // ここで state 内の sessionId を利用
          );
          setState(() {
            responseText = resultMessage.message;
          });
        } catch (e) {
          setState(() {
            responseText = "エラーが発生しました";
          });
        }
      }
    } else {
      // 音声認識開始
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          transcript = "";
          responseText = "";
        });
        await _speechToText.listen(
          localeId: "ja_JP",
          onResult: (result) {
            setState(() {
              transcript = result.recognizedWords;
            });
          },
        );
        setState(() {
          isListening = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅行計画お助けマン'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 録音内容表示
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                transcript.isNotEmpty ? '入力音声: $transcript' : 'ここに音声内容が表示されます',
              ),
            ),
            if (responseText.isNotEmpty)
              Markdown(
                shrinkWrap: true,
                data: sanitizeMarkdown(responseText),
                physics: const NeverScrollableScrollPhysics(),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("サーバーから返ってくるとここに表示されます"),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(isListening ? Icons.pause : Icons.mic),
        onPressed: toggleListening,
      ),
    );
  }

  String sanitizeMarkdown(String response) {
    // 先頭の ```markdown と末尾の ``` を正規表現で削除
    final sanitized = response
        .replaceAll(RegExp(r'^```markdown\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '');
    return sanitized;
  }
}
