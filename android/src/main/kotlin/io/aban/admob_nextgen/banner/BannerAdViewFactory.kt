package io.aban.admob_nextgen.banner

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Creates banner views with the current Activity supplied by the plugin lifecycle. */
class BannerAdViewFactory(
    private val messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = (args as? Map<String, Any?>) ?: emptyMap()
        return NextGenBannerAdView(
            hostContext = context,
            activity = activityProvider(),
            viewId = viewId,
            messenger = messenger,
            creationParams = params,
        )
    }
}

