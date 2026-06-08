package io.aban.admob_nextgen.core

import com.google.android.libraries.ads.mobile.sdk.common.AdRequest
import com.google.android.libraries.ads.mobile.sdk.common.BaseRequestBuilder
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdRequest
import com.google.android.libraries.ads.mobile.sdk.banner.AdSize
import com.google.android.libraries.ads.mobile.sdk.common.VideoOptions
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdRequest

/** Applies Dart targeting params to any SDK request builder. */
@Suppress("UNCHECKED_CAST")
internal fun <T : BaseRequestBuilder<T>> Map<String, Any?>?.applyTargetingTo(
    builder: BaseRequestBuilder<T>,
) {
    val params = this ?: return
    (params["keywords"] as? List<*>)?.forEach {
        if (it is String) builder.addKeyword(it)
    }
    (params["customTargeting"] as? Map<*, *>)?.forEach { (k, v) ->
        if (k is String) {
            when (v) {
                is String -> builder.putCustomTargeting(k, v)
                is List<*> -> builder.putCustomTargeting(k, v.filterIsInstance<String>())
            }
        }
    }
    (params["contentUrl"] as? String)?.let { builder.setContentUrl(it) }
    (params["neighboringContentUrls"] as? List<*>)?.let { urls ->
        builder.setNeighboringContentUrls(urls.filterIsInstance<String>().toSet())
    }
    (params["requestAgent"] as? String)?.let { builder.setRequestAgent(it) }
    (params["categoryExclusions"] as? List<*>)?.forEach {
        if (it is String) builder.addCategoryExclusion(it)
    }
    (params["publisherProvidedId"] as? String)?.let { builder.setPublisherProvidedId(it) }
    (params["placementId"] as? Number)?.let { builder.setPlacementId(it.toLong()) }
}

/** Builds a standard ad request with optional targeting. */
internal fun buildAdRequest(adUnitId: String, params: Map<String, Any?>?): AdRequest {
    val builder = AdRequest.Builder(adUnitId)
    params.applyTargetingTo(builder)
    return builder.build()
}

/** Builds a banner request with optional targeting. */
internal fun buildBannerAdRequest(
    adUnitId: String,
    size: AdSize,
    params: Map<String, Any?>?,
): BannerAdRequest {
    val builder = BannerAdRequest.Builder(adUnitId, size)
    params.applyTargetingTo(builder)
    return builder.build()
}

/** Builds a native ad request with optional targeting and video options. */
internal fun buildNativeAdRequest(
    adUnitId: String,
    params: Map<String, Any?>?,
    options: Map<String, Any?>?,
): NativeAdRequest {
    val builder = NativeAdRequest.Builder(adUnitId, listOf(NativeAd.NativeAdType.NATIVE))
    params.applyTargetingTo(builder)
    val startMuted = (options?.get("startVideoMuted") as? Boolean) ?: true
    builder.setVideoOptions(VideoOptions.Builder().setStartMuted(startMuted).build())
    return builder.build()
}


internal fun platformErrorCode(code: Any?): Int = when (code) {
    is Number -> code.toInt()
    is Enum<*> -> code.ordinal
    else -> -1
}

internal fun platformErrorName(code: Any?): String = when (code) {
    is Enum<*> -> code.name
    null -> "unknown"
    else -> code.toString()
}
