import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:web_vuw/web_vuw.dart';
import 'package:web_vuw_example/popup_screen.dart';

void main() => runApp(MaterialApp(home: Example()));

class Example extends StatefulWidget {
  @override
  createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Completer<WebVuwController> _controller = Completer<WebVuwController>();
  StreamSubscription _ssWebVuwEvents;
  String _loadUrl = 'https:/flutter.io';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebVuwController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebVuwController> snapshot) {
        final webViewReady = snapshot.connectionState == ConnectionState.done;
        final controller = snapshot.data;

        if (webViewReady) {
          _ssWebVuwEvents = controller.onEvents().listen((events) {
            print('Events 😎=> $events');
          });
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.red,
              title: Text('Web Vuw'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    showSnackBar("Can Show Snak Bar 😎");
                  },
                ),
                IconButton(
                  icon: Icon(Icons.palette),
                  onPressed: () async {
                    final controller = await _controller.future;
                    final result = await controller.evaluateJavascript(
                        'document.body.style.backgroundColor = \'cyan\'');
                    print('result -> $result');
                  },
                ),
                IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      popupScreen(PopupScreen(), context);
                    }),
                IconButton(
                    icon: Icon(Icons.code),
                    onPressed: () async {
                      final controller = await _controller.future;
                      await controller
                          .loadHtml('<body><h1>this is web vuw</h1></body>');
                    })
              ]),
          body: WebVuw(
//             to load web page url
            initialUrl: _loadUrl,
            // to load html string
//            html: '<body><h1>this is web vuw</h1></body>',
            enableJavascript: true,
            pullToRefresh: false,
            userAgent: 'userAgent',
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            ].toSet(),
            javaScriptMode: JavaScriptMode.unrestricted,
            onWebViewCreated: (WebVuwController webViewController) {
              _controller.complete(webViewController);
            },
          ),
        );
      },
    );
  }

  showSnackBar(String message) =>
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ));

  @override
  void dispose() {
    if (_ssWebVuwEvents != null) _ssWebVuwEvents.cancel();
    super.dispose();
  }
}

popupScreen(Widget screen, BuildContext context) => Navigator.push(
    context,
    PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => screen,
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child, // child is the value returned by pageBuilder
            )));
