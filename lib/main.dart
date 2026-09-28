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
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _setupController() {
    hasError = false;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF05060D))
      ..setNavigationDelegate(
        NavigationDelegate(
          // Kalau server lagi mati/nggak bisa dihubungi (misal Termux-nya
          // lagi off), tampilin layar error rapi + tombol coba lagi —
          // bukan halaman error mentah bawaan Android. PENTING: cuma
          // reagen kalau yang gagal itu HALAMAN UTAMANYA (isForMainFrame),
          // bukan tiap resource kecil di dalam halaman (gambar, satu
          // panggilan data yang sempet timeout, dll) — kalau nggak
          // dibatesin gini, satu request kecil gagal aja bakal nutupin
          // seluruh dashboard yang sebenernya udah kebuka normal.
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame != false) {
              setState(() => hasError = true);
            }
          },
        ),
      );
    // BUG FIX: "net::ERR_CACHE_MISS" muncul di sebagian WebView Android pas
    // load pertama kali abis fresh-install — cache HTTP internalnya belum
    // sempet ke-inisialisasi pas request pertama ditembak. Bersihin cache
    // dulu sebelum load pertama biar WebView mulai dari kondisi bersih,
    // bukan nyoba baca dari cache yang belum ada isinya.
    controller.clearCache().then((_) {
      controller.loadRequest(Uri.parse(quantxUrl));
    });
  }

  void _retry() {
    setState(() {
      _setupController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060D),
      body: SafeArea(
        child: hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white38, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Nggak bisa nyambung ke server.\nPastikan server QuantX lagi nyala.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DA8FF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : WebViewWidget(controller: controller),
      ),
    );
  }
}
