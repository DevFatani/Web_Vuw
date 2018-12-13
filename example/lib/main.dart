import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:web_vuw/web_vuw.dart';

void main() => runApp(MaterialApp(home: Example()));

class Example extends StatefulWidget {
  @override
  createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Completer<WebVuwController> _controller = Completer<WebVuwController>();
  StreamSubscription _ssWebVuwEvents;
  String _loadUrl = 'https://unsplash.com/public-domain-images';
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
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      popupScreen(PopupScreen());
                    })
              ]),
          body: WebVuw(
            initialUrl: _loadUrl,
            enableJavascript: true,
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

  popupScreen(Widget screen) => Navigator.push(
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

  @override
  void dispose() {
    if (_ssWebVuwEvents != null) _ssWebVuwEvents.cancel();
    super.dispose();
  }
}

class PopupScreen extends StatefulWidget {
  @override
  createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  double boxWidth;
  double boxHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Stack(
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: null,
            ),
            Center(
              child: Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.5)),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Center(
                      child: Text(
                    "Hello this Web Vuw",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
          ],
        ));
  }
}
