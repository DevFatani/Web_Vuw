# web_vuw

### A Plugin that can embedded web view with flutter widgets.


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
        header: {
            .....
        }
        userAgent: 'userAgent',
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
Future<Boolean> hasForward();
```
```dart
Future<Boolean> forward();
```

```dart
Stream onEvents;
```
