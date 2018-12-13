package com.devfatani.webvuw

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class WebVuwFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    val TAG = "WebVuwFactory"
    override fun create(context: Context, id: Int, args: Any): PlatformView {
        val params = args as Map<*, *>
        return WebVuw(context, messenger, id, params)
    }
}
