package io.aban.admob_nextgen.native_ads

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.aban.admob_nextgen.R
import io.flutter.plugin.platform.PlatformView

internal enum class NativeAdLayout(val resourceId: Int) {
    BANNER(R.layout.native_banner_ad),
    SMALL(R.layout.native_small_ad),
    LARGE(R.layout.native_large_ad),
}

internal class NextGenNativeAdView(
    context: Context,
    private val creationParams: Map<String, Any?>,
    nativeAdManager: NativeAdManager,
    layout: NativeAdLayout,
) : PlatformView {

    private val container = FrameLayout(context)
    private var disposed = false

    init {
        val adId = creationParams["adId"] as? String
        val nativeAd = adId?.let { nativeAdManager.get(it) }
        if (nativeAd != null) {
            bindNativeAd(context, nativeAd, layout)
        }
    }

    private fun bindNativeAd(
        context: Context,
        nativeAd: NativeAd,
        layout: NativeAdLayout,
    ) {
        val root = LayoutInflater.from(context).inflate(
            layout.resourceId,
            container,
            false,
        ) as NativeAdView

        val headline = root.findViewById<TextView>(R.id.ad_headline)
        val body: TextView? = root.findViewById(R.id.ad_body)
        val badge = root.findViewById<TextView>(R.id.ad_badge)
        val callToAction = root.findViewById<Button>(R.id.ad_call_to_action)
        val icon = root.findViewById<ImageView>(R.id.ad_icon)
        val media: MediaView? = root.findViewById(R.id.ad_media)
        applyStyles(root, headline, body, badge, callToAction, creationParams)

        root.headlineView = headline
        if (body != null) root.bodyView = body
        root.callToActionView = callToAction
        root.iconView = icon

        val callToActionText =
            (creationParams["callToActionText"] as? String)
                ?.takeIf { it.isNotBlank() }
                ?: nativeAd.callToAction

        headline.text = nativeAd.headline
        callToAction.text = callToActionText
        icon.setImageDrawable(nativeAd.icon?.drawable)
        body?.text = nativeAd.body
        body?.visibility = nativeAd.body.visibilityOrGone()
        callToAction.visibility = callToActionText.visibilityOrGone()
        icon.visibility = nativeAd.icon.visibilityOrGone()

        container.addView(root)

        if (layout == NativeAdLayout.LARGE) {
            val largeMedia = requireNotNull(media) {
                "Large native ad layout must contain a MediaView."
            }
            // Flutter creates the platform view before its first layout pass.
            // Wait until the MediaView has a real measured size so the Native
            // Validator does not inspect it as 0x0.
            largeMedia.post {
                if (!disposed && largeMedia.isAttachedToWindow) {
                    root.registerNativeAd(nativeAd, largeMedia)
                }
            }
        } else {
            // Banner and small templates intentionally do not render media.
            root.registerNativeAd(nativeAd, null)
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        disposed = true
        container.removeAllViews()
    }

    private fun Any?.visibilityOrGone(): Int = if (this == null) View.GONE else View.VISIBLE

    private fun applyStyles(
        root: NativeAdView,
        headline: TextView,
        body: TextView?,
        badge: TextView,
        callToAction: Button,
        creationParams: Map<String, Any?>,
    ) {
        creationParams.colorInt("cardColor")?.let { root.applyBackgroundColor(it) }
        creationParams.colorInt("titleColor")?.let { headline.setTextColor(it) }
        creationParams.colorInt("descriptionColor")?.let { body?.setTextColor(it) }
        (creationParams["adBadgeText"] as? String)
            ?.takeIf { it.isNotBlank() }
            ?.let { badge.text = it }
        creationParams.colorInt("adBadgeTextColor")?.let { badge.setTextColor(it) }
        applyBadgeBackground(badge, creationParams)
        creationParams.colorInt("callToActionColor")?.let { callToAction.applyBackgroundColor(it) }
        creationParams.colorInt("callToActionTextColor")?.let { callToAction.setTextColor(it) }
        creationParams.dpFloat("callToActionHeight")?.let {
            callToAction.updateHeight(it.toPixels(callToAction.context))
        }
        creationParams.dpFloat("callToActionCornerRadius")?.let {
            callToAction.updateCornerRadius(it.toPixels(callToAction.context).toFloat())
        }
    }

    private fun applyBadgeBackground(
        badge: TextView,
        creationParams: Map<String, Any?>,
    ) {
        val backgroundColor = creationParams.colorInt("adBadgeColor")
        val borderColor = creationParams.colorInt("adBadgeBorderColor")
        val borderWidth = creationParams.dpFloat("adBadgeBorderWidth")
            ?.toPixels(badge.context)
        val cornerRadius = creationParams.dpFloat("adBadgeCornerRadius")
            ?.toPixels(badge.context)
            ?.toFloat()
        if (
            backgroundColor == null &&
            borderColor == null &&
            borderWidth == null &&
            cornerRadius == null
        ) {
            return
        }

        val background = badge.background?.mutate()
        if (background is GradientDrawable) {
            backgroundColor?.let { background.setColor(it) }
            if (borderColor != null || borderWidth != null) {
                background.setStroke(borderWidth ?: 1.toPixels(badge.context), borderColor ?: Color.TRANSPARENT)
            }
            cornerRadius?.let { background.cornerRadius = it }
            badge.background = background
        }
    }

    private fun Map<String, Any?>.colorInt(key: String): Int? {
        return when (val value = this[key]) {
            is Number -> value.toInt()
            is String -> runCatching { Color.parseColor(value) }.getOrNull()
            else -> null
        }
    }

    private fun Map<String, Any?>.dpFloat(key: String): Float? {
        return when (val value = this[key]) {
            is Number -> value.toFloat().takeIf { it >= 0f }
            is String -> value.toFloatOrNull()?.takeIf { it >= 0f }
            else -> null
        }
    }

    private fun Float.toPixels(context: Context): Int {
        return (this * context.resources.displayMetrics.density).toInt()
    }

    private fun Int.toPixels(context: Context): Int {
        return (this * context.resources.displayMetrics.density).toInt()
    }

    private fun View.updateHeight(heightPx: Int) {
        val params = layoutParams ?: ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            heightPx,
        )
        params.height = heightPx
        layoutParams = params
        minimumHeight = 0
    }

    private fun View.updateCornerRadius(radiusPx: Float) {
        val background = background?.mutate()
        if (background is GradientDrawable) {
            background.cornerRadius = radiusPx
            this.background = background
        }
    }

    private fun View.applyBackgroundColor(color: Int) {
        val background = background?.mutate()
        if (background is GradientDrawable) {
            background.setColor(color)
            this.background = background
        } else {
            setBackgroundColor(color)
        }
    }
}
