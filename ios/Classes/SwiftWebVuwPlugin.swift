import Flutter
import UIKit
import WebKit
public class WebVuwFactory : NSObject, FlutterPlatformViewFactory {
    
    var messenger: FlutterBinaryMessenger!
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return WebVuwController(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }
    
    @objc public init(messenger: (NSObject & FlutterBinaryMessenger)?) {
        super.init()
        self.messenger = messenger
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}


public class WebVuwController: NSObject, FlutterPlatformView, FlutterStreamHandler {
    
    
    //PRAMS NAME
    let INITIAL_URL = "initialUrl"
    let HEADER = "header"
    let USER_AGENT = "userAgent"
    let SETTINGS = "settings"
    let CHANNEL_NAME = "plugins.devfatani.com/web_vuw_%d"
    let WEB_VUW_EVENT = "web_vuw_events_%d"
    let EVENT = "event"
    let URL_ = "url"
    let ENABLE_JAVA_SCRIPT = "enableJavascript"
    let ENABLE_LOCAL_STORAGE = "enableLocalStorage"
    
    
    //METHOD NAME
    let LOAD_URL = "loadUrl"
    let CAN_GO_BACK = "canGoBack"
    let CAN_GO_FORWARD = "canGoForward"
    let GO_BACK = "goBack"
    let GO_FORWARD = "goForward"
    let STOP_LOADING = "stopLoading"
    
    fileprivate var viewId:Int64!;
    fileprivate var wkWebVuw: WKWebView!
    fileprivate var channel: FlutterMethodChannel!
    fileprivate var refController: UIRefreshControl!
    fileprivate var eventSinkNavigation: FlutterEventSink?;

    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        super.init()
        
        if let initWebVuw =  self.initWebVuw(frame: frame, args) {
            FlutterEventChannel.init(name: String(format: WEB_VUW_EVENT, viewId),
                                     binaryMessenger: binaryMessenger).setStreamHandler(self)
            
            self.wkWebVuw = initWebVuw
            self.refController = UIRefreshControl()
            self.refController.addTarget(self, action:  #selector(reloadWebView), for: .valueChanged)
            self.wkWebVuw.scrollView.addSubview(self.refController)
            
            let channelName = String(format: CHANNEL_NAME, viewId)
            self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
            
            self.channel.setMethodCallHandler({
                [weak self]
                (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                if let this = self {
                    this.onMethodCall(call: call, result: result)
                }
            })
        }
    }
    
    private func initWebVuw (frame: CGRect, _ args: Any?) -> WKWebView? {
        if let params = args as? NSDictionary ,
            let initialURLString = params[INITIAL_URL] as? String {
            
            let initialURL = URL(string: initialURLString)!
            var customRequest = URLRequest(url: initialURL)
            
            if let header = params[HEADER] as? NSDictionary {
                for (key, value) in header {
                    if let val = value as? String,
                        let field = key as? String {
                        customRequest.addValue(val, forHTTPHeaderField: field)
                    }
                }
            }
            
            let enableJavascript =  params[ENABLE_JAVA_SCRIPT] as? Int ?? 0
            let enableLocalStorage = params[ENABLE_LOCAL_STORAGE] as? Int ?? 0
            
            let preferences = WKPreferences()
            let configuration = WKWebViewConfiguration()
            preferences.javaScriptEnabled = enableJavascript == 1
            if #available(iOS 9.0, *), enableLocalStorage == 1{
                configuration.websiteDataStore = WKWebsiteDataStore.default()
            }
            
            
            configuration.preferences = preferences
            let wkWebVuw = WKWebView(frame: frame, configuration: configuration)
            wkWebVuw.navigationDelegate = self
            wkWebVuw.scrollView.bounces = true
            
            if #available(iOS 9.0, *),
                let userAgent = params[USER_AGENT] as? String {
                wkWebVuw.customUserAgent = userAgent
            }
            
            wkWebVuw.load(customRequest)
            
            return wkWebVuw
        }
        
        return nil
        
    }
    
    public func view() -> UIView {
        return self.wkWebVuw
    }
    
    @objc func reloadWebView(){
        self.refController.endRefreshing()
    }
    
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        if method == LOAD_URL {
            self.onLoadURL(call, result)
        }else if method == CAN_GO_BACK{
            self.onCanGoBack(call, result)
        }else  if method == CAN_GO_FORWARD {
            self.onCanGoForward(call, result)
        }else  if method == GO_BACK {
            self.onGoBack(call, result)
        }else  if method == GO_FORWARD {
            self.onGoForward(call, result)
        }else if method == STOP_LOADING {
            self.onStopLoading(call, result)
        }
    }
    
    
    func onLoadURL(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let url = call.arguments as? String  {
            if !load(url: url) {
                result(FlutterError(code: "loadURL_faild", message: "faild parsing url", details: "Your [URL] was: \(url)"))
            }else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    func load(url:String)-> Bool {
        if let urlRequest = URL(string: url) {
            self.wkWebVuw.load(URLRequest(url: urlRequest))
            return true
        }
        return false
    }
    
    func onCanGoBack(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let canGoBack = wkWebVuw.canGoBack
        result([NSNumber(booleanLiteral: canGoBack)])
    }
    
    func onCanGoForward(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let canGoForward = wkWebVuw.canGoForward
        result([NSNumber(booleanLiteral: canGoForward)])
    }
    
    func onGoBack(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        wkWebVuw.goBack()
        result(nil)
    }
    
    func onGoForward(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        wkWebVuw.goForward()
        result(nil)
    }
    
    func onStopLoading(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        self.wkWebVuw.stopLoading()
        result(nil)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSinkNavigation = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return FlutterError(code: "stream_fail", message: "could not streaming", details: nil)
    }
    
    public func fireEvent(event:String, webView: WKWebView) {
        if let sink = self.eventSinkNavigation,
            let url = webView.url?.absoluteString{
            sink([
                EVENT: event,
                URL_: url
                ])
        }
    }
}

extension WebVuwController : WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        fireEvent(event: "didStartProvisionalNavigation", webView: webView)
    }
    
    
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        fireEvent(event: "didStart", webView: webView)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        fireEvent(event: "didFinish", webView: webView)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.response is HTTPURLResponse {
            let response = navigationResponse.response as! HTTPURLResponse
            if response.statusCode != 200 {
                fireEvent(event: "navigationResponse", webView: webView)
            }
            decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
        }
    }


}

