import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Gardenia Kosmetyka Market',
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            }
          },
          child: const Icon(CupertinoIcons.back),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: () => _controller.reload(),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            WebView(
              initialUrl: 'https://gardeniakosmetyka.com/gardenia',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _loadingProgress = progress / 100;
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              gestureNavigationEnabled: true,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              userAgent:
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
            ),
            if (_isLoading)
              Container(
                color: CupertinoColors.systemBackground.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(radius: 16),
                      const SizedBox(height: 16),
                      Text(
                        'Loading... ${(_loadingProgress * 100).toInt()}%',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
