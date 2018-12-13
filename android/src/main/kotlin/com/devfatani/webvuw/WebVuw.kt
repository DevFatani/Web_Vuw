package com.devfatani.webvuw

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.view.View
import android.webkit.WebView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView
import android.support.v4.widget.SwipeRefreshLayout
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.webkit.WebViewClient
import android.widget.LinearLayout
import io.flutter.plugin.common.EventChannel


class WebVuw internal constructor(
        context: Context,
        messenger: BinaryMessenger,
        id: Int,
        params: Map<*, *>) :
        PlatformView,
        MethodCallHandler,
        SwipeRefreshLayout.OnRefreshListener,
        EventChannel.StreamHandler {

    val TAG = "WebVuw"

    //PRAMS NAME
    val INITIAL_URL = "initialUrl"
    val HEADER = "header"
    val USER_AGENT = "userAgent"
    val CHANNEL_NAME = "plugins.devfatani.com/web_vuw_"
    val WEB_VUW_EVENT = "web_vuw_events_"
    val EVENT = "event"
    val URL = "url"
    val ENABLE_JAVA_SCRIPT = "enableJavascript"
    val ENABLE_LOCAL_STORAGE = "enableLocalStorage"

    //METHOD NAME
    val LOAD_URL = "loadUrl"
    val CAN_GO_BACK = "canGoBack"
    val CAN_GO_FORWARD = "canGoForward"
    val GO_BACK = "goBack"
    val GO_FORWARD = "goForward"
    val STOP_LOADING = "stopLoading"

    private val linearLay = LinearLayout(context)

    private val swipeRefresh: SwipeRefreshLayout = SwipeRefreshLayout(context)
    private val webVuw: WebView = WebView(context)
    private val methodChannel: MethodChannel

    private var eventSinkNavigation: EventChannel.EventSink? = null

    init {
        if (params.containsKey(INITIAL_URL)) {
            val initialURL = params[INITIAL_URL] as String

            if (params[HEADER] != null) {
                val header = params[HEADER] as Map<String, String>
                webVuw.loadUrl(initialURL, header)
            } else webVuw.loadUrl(initialURL)

            if (params[USER_AGENT] != null) {
                val userAgent = params[USER_AGENT] as String
                webVuw.settings.userAgentString = userAgent
            }


            val isJavaScriptEnabled = params[ENABLE_JAVA_SCRIPT] as Boolean
            val isLocalStorageEnabled = params[ENABLE_LOCAL_STORAGE] as Boolean
            webVuw.settings.javaScriptEnabled = isJavaScriptEnabled
            webVuw.settings.domStorageEnabled = isLocalStorageEnabled

            val self = this@WebVuw
            webVuw.webViewClient = object : WebViewClient() {
                override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                    super.onPageStarted(view, url, favicon)
                    if (self.eventSinkNavigation != null && url != null) {
                        val result = HashMap<String, String>().apply {
                            put(EVENT, "onPageStarted")
                            put(URL, url)
                        }
                        self.eventSinkNavigation!!.success(result)
                    }
                }

                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    if (self.eventSinkNavigation != null && url != null) {
                        val result = HashMap<String, String>().apply {
                            put(EVENT, "onPageFinished")
                            put(URL, url)
                        }
                        self.eventSinkNavigation!!.success(result)
                    }
                }
            }

            linearLay.orientation = LinearLayout.VERTICAL
            swipeRefresh.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT)
            webVuw.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT)
            linearLay.addView(swipeRefresh)
            swipeRefresh.addView(webVuw)
            swipeRefresh.setOnRefreshListener(this@WebVuw)

//            SHOW Keyboard
//            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).apply {
//                toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
//            }

            EventChannel(messenger, "$WEB_VUW_EVENT$id").setStreamHandler(this@WebVuw)
        }

        methodChannel = MethodChannel(messenger, "$CHANNEL_NAME$id")
        methodChannel.setMethodCallHandler(this@WebVuw)
    }

    override fun getView(): View {
        return linearLay
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        when (methodCall.method) {
            LOAD_URL -> loadUrl(methodCall, result)
            CAN_GO_BACK -> canGoBack(methodCall, result)
            CAN_GO_FORWARD -> canGoForward(methodCall, result)
            GO_BACK -> goBack(methodCall, result)
            GO_FORWARD -> goForward(methodCall, result)
            STOP_LOADING -> stopLoading(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun stopLoading(methodCall: MethodCall, result: Result) {
        webVuw.stopLoading()
        result.success(null)
    }

    private fun loadUrl(methodCall: MethodCall, result: Result) {
        val url = methodCall.arguments as String
        webVuw.loadUrl(url)
        result.success(null)
    }

    private fun canGoBack(methodCall: MethodCall, result: Result) {
        result.success(webVuw.canGoBack())
    }

    private fun canGoForward(methodCall: MethodCall, result: Result) {
        result.success(webVuw.canGoForward())
    }

    private fun goBack(methodCall: MethodCall, result: Result) {
        if (webVuw.canGoBack()) {
            webVuw.goBack()
        }
        result.success(null)
    }

    private fun goForward(methodCall: MethodCall, result: Result) {
        if (webVuw.canGoForward()) {
            webVuw.goForward()
        }
        result.success(null)
    }

    override fun onRefresh() {
        webVuw.reload()
        swipeRefresh.isRefreshing = false
    }

    override fun dispose() {}

    override fun onListen(args: Any?, event: EventChannel.EventSink?) {
        eventSinkNavigation = event
    }

    override fun onCancel(p0: Any?) {
    }
}