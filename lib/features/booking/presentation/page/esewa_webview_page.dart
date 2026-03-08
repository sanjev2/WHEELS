import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/esewa_initiate_entity.dart';

class EsewaWebViewPage extends StatefulWidget {
  final EsewaInitiateEntity esewa;
  const EsewaWebViewPage({super.key, required this.esewa});

  @override
  State<EsewaWebViewPage> createState() => _EsewaWebViewPageState();
}

class _EsewaWebViewPageState extends State<EsewaWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            final url = req.url;

            if (url.startsWith("wheels://payment/success")) {
              _showDone("Payment Success");
              return NavigationDecision.prevent;
            }
            if (url.startsWith("wheels://payment/failure")) {
              _showDone("Payment Failed");
              return NavigationDecision.prevent;
            }

            // keep old checks (optional)
            if (url.contains("paid=1")) {
              _showDone("Payment Success");
              return NavigationDecision.prevent;
            }
            if (url.contains("status=FAILED") ||
                url.contains("status=BAD_SIGNATURE")) {
              _showDone("Payment Failed");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _loadEsewaForm();
  }

  void _showDone(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> _loadEsewaForm() async {
    final esewaUrl = widget.esewa.esewaUrl;
    final fields = widget.esewa.fields;

    final inputs = fields.entries
        .map((e) => '<input type="hidden" name="${e.key}" value="${e.value}"/>')
        .join("\n");

    final html =
        """
    <html>
      <body onload="document.f.submit();">
        <form name="f" method="POST" action="$esewaUrl">
          $inputs
        </form>
        <p style="font-family:Arial;padding:16px;">Redirecting to eSewa...</p>
      </body>
    </html>
    """;

    await _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("eSewa Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
