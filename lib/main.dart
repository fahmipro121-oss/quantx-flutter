import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// URL server QuantX kamu (lewat Cloudflare Tunnel). Ganti baris ini kalau
// linknya berubah (misal abis Termux di-restart ulang).
const String quantxUrl = "https://moscow-karl-wednesday-saying.trycloudflare.com";

void main() {
  runApp(const QuantXApp());
}

class QuantXApp extends StatelessWidget {
  const QuantXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const QuantXWebView(),
    );
  }
}

class QuantXWebView extends StatefulWidget {
  const QuantXWebView({super.key});

  @override
  State<QuantXWebView> createState() => _QuantXWebViewState();
}

class _QuantXWebViewState extends State<QuantXWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF05060D))
      ..loadRequest(Uri.parse(quantxUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060D),
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
