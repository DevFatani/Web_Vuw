import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void WebViewCreatedCallback(WebVuwController controller);

enum JavaScriptMode {
  /// JavaScript execution is disabled.
  disabled,

  /// JavaScript execution is not restricted.
  unrestricted,
}

class WebVuwController {
  WebVuwController._(int id)
      : _channel = MethodChannel('plugins.devfatani.com/web_vuw_$id'),
        this._webVuwEvents = EventChannel('web_vuw_events_$id');

  final EventChannel _webVuwEvents;

  final MethodChannel _channel;

  Future<void> loadUrl(String url) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', url);
  }

  Future<bool> canGoBack() async {
    final bool canGoBack = await _channel.invokeMethod("canGoBack");
    return canGoBack;
  }

  Future<bool> canGoForward() async {
    final bool canGoForward = await _channel.invokeMethod("canGoForward");
    return canGoForward;
  }

  Future<void> goBack() async {
    return _channel.invokeMethod("goBack");
  }

  Future<void> goForward() async {
    return _channel.invokeMethod("goForward");
  }

  Future<void> stopLoading() async {
    return _channel.invokeMethod("stopLoading");
  }

  Future<void> reload() async {
    return _channel.invokeMethod("reload");
  }

  Future<dynamic> evaluateJavascript(String javascriptString) async {
    final result =
        await _channel.invokeMethod('evaluateJavascript', javascriptString);
    return result;
  }

  Future<void> loadHtml(String html) async {
    final result = await _channel.invokeMethod('loadHtml', html);
    return result;
  }

  Future<void> _updateSettings(Map<String, dynamic> update) async {
    return _channel.invokeMethod('updateSettings', update);
  }

  Stream onEvents() {
    return _webVuwEvents.receiveBroadcastStream();
  }
}

class WebVuw extends StatefulWidget {
  const WebVuw(
      {Key key,
      this.onWebViewCreated,
      this.initialUrl,
      this.header,
      this.enableJavascript,
      this.enableLocalStorage = false,
      this.userAgent,
      this.javaScriptMode = JavaScriptMode.disabled,
      this.gestureRecognizers,
      this.html,
      this.pullToRefresh})
      : assert(javaScriptMode != null),
        super(key: key);

  final WebViewCreatedCallback onWebViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  final Map header;
  final String userAgent;
  final bool enableJavascript;
  final bool enableLocalStorage;
  final String initialUrl;
  final String html;
  final bool pullToRefresh;

  final JavaScriptMode javaScriptMode;

  @override
  State<StatefulWidget> createState() => _WebVuwState();
}

class _WebVuwState extends State<WebVuw> {
  final Completer<WebVuwController> _controller = Completer<WebVuwController>();

  _WebSettings _settings;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
        onLongPress: () {},
        child: AndroidView(
          viewType: 'plugins.devfatani.com/web_vuw',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          layoutDirection: TextDirection.rtl,
          creationParams: _CreationParams.fromWidget(widget).toMap(),
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.devfatani.com/web_vuw',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webview_flutter plugin');
  }

  @override
  void initState() {
    super.initState();
    _settings = _WebSettings.fromWidget(widget);
  }

  @override
  void didUpdateWidget(WebVuw oldWidget) {
    super.didUpdateWidget(oldWidget);
    final _WebSettings newSettings = _WebSettings.fromWidget(widget);
    final Map<String, dynamic> settingsUpdate =
        _settings.updatesMap(newSettings);
    _updateSettings(settingsUpdate);
    _settings = newSettings;
  }

  Future<void> _updateSettings(Map<String, dynamic> update) async {
    if (update == null) {
      return;
    }
    final WebVuwController controller = await _controller.future;
    controller._updateSettings(update);
  }

  void _onPlatformViewCreated(int id) {
    final WebVuwController controller = WebVuwController._(id);
    _controller.complete(controller);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated(controller);
    }
  }
}

class _WebSettings {
  _WebSettings({
    this.javaScriptMode,
  });

  static _WebSettings fromWidget(WebVuw widget) {
    return _WebSettings(javaScriptMode: widget.javaScriptMode);
  }

  final JavaScriptMode javaScriptMode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jsMode': javaScriptMode.index,
    };
  }

  Map<String, dynamic> updatesMap(_WebSettings newSettings) {
    if (javaScriptMode == newSettings.javaScriptMode) {
      return null;
    }
    return <String, dynamic>{
      'jsMode': newSettings.javaScriptMode.index,
    };
  }
}

class _CreationParams {
  _CreationParams(
      {this.initialUrl,
      this.header,
      this.enableJavascript,
      this.enableLocalStorage,
      this.userAgent,
      this.settings,
      this.html,
      this.pullToRefresh});

  static _CreationParams fromWidget(WebVuw widget) {
    return _CreationParams(
        initialUrl: widget.initialUrl,
        header: widget.header,
        enableJavascript: widget.enableJavascript,
        enableLocalStorage: widget.enableLocalStorage,
        userAgent: widget.userAgent,
        settings: _WebSettings.fromWidget(widget),
        html: widget.html,
        pullToRefresh: widget.pullToRefresh);
  }

  final String initialUrl;
  final Map header;
  final bool enableJavascript;
  final bool enableLocalStorage;
  final _WebSettings settings;
  final String userAgent;
  final String html;
  final bool pullToRefresh;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'initialUrl': initialUrl,
      'header': header,
      'enableJavascript': enableJavascript,
      'enableLocalStorage': enableLocalStorage,
      'userAgent': userAgent,
      'settings': settings.toMap(),
      'html': html,
      'pullToRefresh': pullToRefresh
    };
  }
}
