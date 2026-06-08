package io.aban.admob_nextgen.native_ads

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class NativeAdViewFactory(
    private val nativeAdManager: NativeAdManager,
    private val layout: NativeAdLayout,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = (args as? Map<String, Any?>) ?: emptyMap()
        return NextGenNativeAdView(
            context = context,
            creationParams = params,
            nativeAdManager = nativeAdManager,
            layout = layout,
        )
    }
}
