# web_vuw

### A plugin that can embedded (web view) with flutter widgets.

### The web view on iOS support by [wkwebview](https://developer.apple.com/documentation/webkit/wkwebview)

### The web view on Android support by [WebView](https://developer.android.com/reference/android/webkit/WebView) 

> 📣 important note
> * Android keyboard cannot be appear according to this flutter issue [19718](https://github.com/flutter/flutter/issues/19718)
> * Not support scrollview

> support
   > * Can embedded in widget tree ✅
   > * Pull to refresh (true / false) ✅
   > * Add header ✅
   > * Add userAgent ✅
   > * Can handl all webview callback method ✅
   > * Can call evaluateJavascript ✅
   > * Can load HTML ✅


# Demo
![alt-text-1](https://media.giphy.com/media/BpaE1Jx8UvLWuVX18v/giphy.gif "demo")

#### NOTE: For iOS you need to put the key => ```io.flutter.embedded_views_preview```   and the value ``` YES ``` in ```Info.plist``` 

## To use this plugin:
* add the dependency to your [pubspec.yaml](https://github.com/DevFatani/Web_Vuw/blob/master/pubspec.yaml) file.


```yaml
    dependencies:
       flutter:
        sdk: flutter
       web_vuw:
```

## How it works
See Full example in [example](https://github.com/DevFatani/Web_Vuw/blob/master/example/lib/main.dart)

`Basic`
```dart
    new WebVuw(
        initialUrl: 'www.url.com',
        enableJavascript: true,
        pullToRefresh: true,
        header: {
            .....
        }
        userAgent: 'userAgent',
        // to load html string
        // html: '<body><h1>this is web vuw</h1></body>',
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
            ),
        ].toSet(),
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebVuwController webViewController) {
            _controller.complete(webViewController);
        }
    )
```


# Listen to webview events

## First 1️⃣ 👇🏻
```dart

//    ...
    StreamSubscription _ssWebVuwEvents;

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<WebVuwController>(
        future: _controller.future,
        builder:
            (BuildContext context, AsyncSnapshot<WebVuwController> snapshot) {
            final webViewReady = 
                snapshot.connectionState == ConnectionState.done;
            final controller = snapshot.data;

            if (webViewReady) {
                // You can now call the functions
                // controller.stopLoading();
                _ssWebVuwEvents = controller.onEvents().listen((events) {
                    print('Events 😎=> $events');
                });
            }
    ...
```


## Second 2️⃣ 👇🏻
```dart
    @override
    void dispose() {
        if (_ssWebVuwEvents != null) _ssWebVuwEvents.cancel();
        super.dispose();
    }
    ..
```

# Functions 👨🏻‍💻

```dart
Future<void> loadUrl(String url);
```
```dart
Future<bool> canGoBack();
```
```dart
Future<bool> canGoForward();
```
```dart
Future<void> goBack();
```
```dart
Future<void> goForward();
```
```dart
Future<void> stopLoading();
```

```dart
Future<void> reload();
```

```dart
Future<void> forward();
```

```dart
Future<dynamic> evaluateJavascript(String javascriptString);
```

```dart
 Future<void> loadHtml(String html);
```

```dart
Stream onEvents;
```
