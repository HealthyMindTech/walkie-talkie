import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../config.dart';

class Backend {
  Future<WebSocketChannel> startWebsocket(String supabaseToken, String explorerName) async {
    final webSocket = WebSocketChannel.connect(Uri.parse(AppConfig.apiHost));

    webSocket.sink.add(jsonEncode({
      "type": "login",
      "token": supabaseToken,
      "explorerName": explorerName,
    }));

    return webSocket;
  }
}
