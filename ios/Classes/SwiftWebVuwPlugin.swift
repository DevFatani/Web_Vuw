import Flutter
import UIKit
import WebKit

enum FlutterMethodName: String {
    case loadUrl
    case canGoBack
    case canGoForward
    case goBack
    case goForward
    case stopLoading
    case evaluateJavascript
    case reload
    case loadHtml
}

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
    let HTML = "html"
    let ENABLE_JAVA_SCRIPT = "enableJavascript"
    let ENABLE_LOCAL_STORAGE = "enableLocalStorage"
    
    
    
    fileprivate var viewId:Int64!;
    fileprivate var wkWebVuw: WKWebView!
    fileprivate var channel: FlutterMethodChannel!
    fileprivate var refController: UIRefreshControl?
    fileprivate var eventSinkNavigation: FlutterEventSink?;
    
    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        super.init()
        
        if let initWebVuw =  self.initWebVuw(frame: frame, args) {
            FlutterEventChannel.init(name: String(format: WEB_VUW_EVENT, viewId),
                                     binaryMessenger: binaryMessenger).setStreamHandler(self)
            
            //TODO: need to refactor
            self.refController = setPullToRefresh(args, wkWebVuw: initWebVuw)
            self.wkWebVuw = initWebVuw
            
            
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
    
    private func jsSettings(params: NSDictionary) -> WKWebViewConfiguration{
        let enableJavascript =  params[ENABLE_JAVA_SCRIPT] as? Int ?? 0
        let enableLocalStorage = params[ENABLE_LOCAL_STORAGE] as? Int ?? 0
        
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        preferences.javaScriptEnabled = enableJavascript == 1
        
        if #available(iOS 9.0, *), enableLocalStorage == 1{
            configuration.websiteDataStore = WKWebsiteDataStore.default()
        }
        
        configuration.preferences = preferences
        
        return configuration
    }
    
    private func setPullToRefresh(_ args: Any?, wkWebVuw: WKWebView) -> UIRefreshControl?{
        if let params = args as? NSDictionary {
            let isPullToRefreshAllowed = params["pullToRefresh"] as? Int ?? 0
            if isPullToRefreshAllowed == 1 {
                let refController = UIRefreshControl()
                refController.addTarget(self, action:  #selector(reloadWebView), for: .valueChanged)
                wkWebVuw.scrollView.addSubview(refController)
                return refController
            }
        }
        return nil
    }
    
    private func initWebVuw (frame: CGRect, _ args: Any?) -> WKWebView? {
        if let params = args as? NSDictionary {
            
            let wkWebVuw = WKWebView(frame: frame, configuration: jsSettings(params: params))
            wkWebVuw.navigationDelegate = self
            wkWebVuw.scrollView.bounces = true
            
            if #available(iOS 9.0, *),
                let userAgent = params[USER_AGENT] as? String {
                wkWebVuw.customUserAgent = userAgent
            }
            
            
            if let initialURLString = params[INITIAL_URL] as? String ,
                let initialURL = URL(string: initialURLString) {
                var customRequest = URLRequest(url: initialURL)
                
                if let header = params[HEADER] as? NSDictionary {
                    for (key, value) in header {
                        if let val = value as? String,
                            let field = key as? String {
                            customRequest.addValue(val, forHTTPHeaderField: field)
                        }
                    }
                }
                wkWebVuw.load(customRequest)
            }else if let html = params[HTML] as? String {
                wkWebVuw.loadHTMLString(html, baseURL: nil)
            }
            
            return wkWebVuw
        }
        
        return nil
        
    }
    
    public func view() -> UIView {
        return wkWebVuw
    }
    
    @objc func reloadWebView(){
        refController?.endRefreshing()
        wkWebVuw.reload()
    }
    
    
    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let method = FlutterMethodName(rawValue: call.method) {
            switch method {
            case .loadUrl:
                onLoadURL(call, result)
            case .canGoBack:
                onCanGoBack(call, result)
            case .canGoForward:
                onCanGoForward(call, result)
            case .goBack:
                onGoBack(call, result)
            case .goForward:
                onGoForward(call, result)
            case .stopLoading:
                onStopLoading(call, result)
            case .evaluateJavascript:
                onEvaluateJavascript(call, result)
            case .reload:
                reload(call, result)
            case .loadHtml:
                onLoadHTML(call, result)
            }
        }
    }
    
    
    func onLoadHTML (_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let html = call.arguments as? String  {
            wkWebVuw.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func onEvaluateJavascript(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let jsString = call.arguments as? String  {
            wkWebVuw.evaluateJavaScript(jsString) { (evaluateResult, error) in
                if error != nil {
                    result(FlutterError(code: "javascribt_faild", message: "Failed evaluating JavaScript Code.", details: "Your [js code] was: \(jsString)"))
                    
                }else if let res =  evaluateResult as? String {
                    result(res)
                }
            }
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
            wkWebVuw.load(URLRequest(url: urlRequest))
            return true
        }
        return false
    }
    
    func onCanGoBack(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let canGoBack = wkWebVuw.canGoBack
        result([NSNumber(booleanLiteral: canGoBack)])
    }
    
    
    func reload(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        wkWebVuw.reload()
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

