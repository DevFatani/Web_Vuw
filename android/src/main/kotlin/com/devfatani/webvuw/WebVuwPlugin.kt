package com.devfatani.webvuw

import io.flutter.plugin.common.PluginRegistry.Registrar

class WebVuwPlugin {

    companion object {

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            registrar
                    .platformViewRegistry()
                    .registerViewFactory(
                            "plugins.devfatani.com/web_vuw", WebVuwFactory(registrar.messenger()));
        }
    }
}
