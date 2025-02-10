import 'package:cloud_functions/cloud_functions.dart';
import 'package:plan_assistant/model/chat_message.dart';

class CloudFunctionsClient {
  final FirebaseFunctions functions =
      FirebaseFunctions.instanceFor(region: 'asia-northeast1');

  Future<ChatMessage> sendMessage(
      {required String text, required String sessionId}) async {
    try {
      final HttpsCallable callable = functions.httpsCallable('detectIntent');
      final result =
          await callable.call({'text': text, 'sessionId': sessionId});
      print("Cloud Function Result: ${result.data}");
      // return
      return ChatMessage(
          message: result.data['result'][0],
          sender: Sender.agent,
          time: DateTime.now(),
          sessionId: sessionId);
      return result.data['result'][0];
    } catch (e) {
      print("Cloud Function Error: $e");
      throw Exception("Cloud Functions の呼び出しに失敗しました");
    }
  }
}
