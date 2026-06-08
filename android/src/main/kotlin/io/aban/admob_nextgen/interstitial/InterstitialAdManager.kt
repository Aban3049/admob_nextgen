package io.aban.admob_nextgen.interstitial

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAd
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAdEventCallback
import io.aban.admob_nextgen.core.buildAdRequest
import io.aban.admob_nextgen.core.toFlutterMap
import io.aban.admob_nextgen.helper.FullScreenAdCoordinator
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

internal class InterstitialAdManager(
    private val channel: MethodChannel,
    private val coordinator: FullScreenAdCoordinator,
)
{

    companion object {
        private const val TAG = "InterstitialAdManager"
    }

    private val ads: MutableMap<String, InterstitialAd> = HashMap()
    private val mainHandler = Handler(Looper.getMainLooper())

    var activity: Activity? = null

    fun load(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val request = buildAdRequest(adUnitId, requestParams)
        InterstitialAd.load(
            request,
            object : AdLoadCallback<InterstitialAd> {
                override fun onAdLoaded(ad: InterstitialAd) {
                    val adId = UUID.randomUUID().toString()
                    ads[adId] = ad
                    attachEventCallbacks(adId, ad)
                    invokeOnMain {
                        result.success(mapOf("adId" to adId, "loaded" to true))
                    }
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    Log.w(TAG, "Interstitial failed to load: $adError")
                    invokeOnMain {
                        result.success(
                            mapOf(
                                "loaded" to false,
                                "error" to adError.toFlutterMap(),
                            )
                        )
                    }
                }
            },
        )
    }

    fun show(adId: String, result: MethodChannel.Result) {
        val ad = ads[adId]
        val act = activity
        if (ad == null) {
            result.error("AD_NOT_FOUND", "No interstitial ad found for id $adId", null)
            return
        }
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is not available to show interstitial.", null)
            return
        }
        if (!coordinator.tryAcquire(adId)) {
            result.error("AD_ALREADY_SHOWING", "Another full-screen ad is already showing.", null)
            return
        }
        try {
            ad.show(act)
            result.success(null)
        } catch (t: Throwable) {
            coordinator.release(adId)
            ads.remove(adId)
            result.error("SHOW_FAILED", t.message, null)
        }
    }

    fun dispose(adId: String) {
        if (coordinator.isActive(adId)) return
        val ad = ads.remove(adId) ?: return
        ad.adEventCallback = null
    }

    /** Adopts a preloaded interstitial for the standard show flow. */
    fun adopt(ad: InterstitialAd): String {
        val adId = java.util.UUID.randomUUID().toString()
        ads[adId] = ad
        attachEventCallbacks(adId, ad)
        return adId
    }

    private fun attachEventCallbacks(adId: String, ad: InterstitialAd) {
        ad.adEventCallback = object : InterstitialAdEventCallback {
            override fun onAdShowedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onInterstitialShowed", mapOf("adId" to adId)) }
            }

            override fun onAdDismissedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onInterstitialDismissed", mapOf("adId" to adId)) }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdFailedToShowFullScreenContent(error: FullScreenContentError) {
                Log.w(TAG, "Interstitial failed to show: $error")
                invokeOnMain {
                    channel.invokeMethod(
                        "onInterstitialFailedToShow",
                        mapOf("adId" to adId) + error.toFlutterMap()
                    )
                }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdImpression() {
                invokeOnMain { channel.invokeMethod("onInterstitialImpression", mapOf("adId" to adId)) }
            }

            override fun onAdClicked() {
                invokeOnMain { channel.invokeMethod("onInterstitialClicked", mapOf("adId" to adId)) }
            }
        }
    }

    private fun invokeOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else mainHandler.post(block)
    }
}
