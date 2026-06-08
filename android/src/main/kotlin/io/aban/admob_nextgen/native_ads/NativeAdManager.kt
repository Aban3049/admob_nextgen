package io.aban.admob_nextgen.native_ads

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdLoader
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdLoaderCallback
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import io.aban.admob_nextgen.core.buildNativeAdRequest
import io.aban.admob_nextgen.core.toFlutterMap

class NativeAdManager(private val channel: MethodChannel) {

    companion object {
        private const val TAG = "NativeAdManager"
    }

    private val ads: MutableMap<String, NativeAd> = HashMap()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun load(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        options: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val request = buildNativeAdRequest(adUnitId, requestParams, options)
        NativeAdLoader.load(
            request,
            object : NativeAdLoaderCallback {
                override fun onNativeAdLoaded(nativeAd: NativeAd) {
                    val adId = UUID.randomUUID().toString()
                    ads[adId] = nativeAd
                    attachEventCallbacks(adId, nativeAd)
                    invokeOnMain {
                        result.success(mapOf("adId" to adId, "loaded" to true))
                    }
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    Log.w(TAG, "Native ad failed to load: $adError")
                    invokeOnMain {
                        result.success(
                            mapOf(
                                "loaded" to false,
                                "error" to adError.toFlutterMap(),
                            ),
                        )
                    }
                }
            },
        )
    }

    fun get(adId: String): NativeAd? = ads[adId]

    fun dispose(adId: String) {
        val ad = ads.remove(adId) ?: return
        ad.adEventCallback = null
        ad.destroy()
    }

    fun disposeAll() {
        val ids = ads.keys.toList()
        ids.forEach { dispose(it) }
    }

    private fun attachEventCallbacks(adId: String, ad: NativeAd) {
        ad.adEventCallback = object : NativeAdEventCallback {
            override fun onAdShowedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onNativeShowed", mapOf("adId" to adId)) }
            }

            override fun onAdDismissedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onNativeDismissed", mapOf("adId" to adId)) }
            }

            override fun onAdFailedToShowFullScreenContent(error: FullScreenContentError) {
                Log.w(TAG, "Native ad failed to show: $error")
                invokeOnMain {
                    channel.invokeMethod(
                        "onNativeFailedToShow",
                        mapOf("adId" to adId) + error.toFlutterMap(),
                    )
                }
            }

            override fun onAdImpression() {
                invokeOnMain { channel.invokeMethod("onNativeImpression", mapOf("adId" to adId)) }
            }

            override fun onAdClicked() {
                invokeOnMain { channel.invokeMethod("onNativeClicked", mapOf("adId" to adId)) }
            }
        }
    }

    private fun invokeOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else mainHandler.post(block)
    }
}
