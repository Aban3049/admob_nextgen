package io.aban.admob_nextgen.app_open

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.libraries.ads.mobile.sdk.appopen.AppOpenAd
import com.google.android.libraries.ads.mobile.sdk.appopen.AppOpenAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import io.aban.admob_nextgen.core.buildAdRequest
import io.aban.admob_nextgen.core.toFlutterMap
import io.aban.admob_nextgen.helper.FullScreenAdCoordinator
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

internal class AppOpenAdManager(
    private val channel: MethodChannel,
    private val coordinator: FullScreenAdCoordinator,
)
{

    companion object {
        private const val TAG = "AppOpenAdManager"

        /** App open ads expire 4 hours after they are loaded. */
        private const val EXPIRY_MILLIS: Long = 4L * 60L * 60L * 1000L
    }

    private data class Entry(val ad: AppOpenAd, val loadedAt: Long)

    private val ads: MutableMap<String, Entry> = HashMap()
    private val mainHandler = Handler(Looper.getMainLooper())

    var activity: Activity? = null

    fun load(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val request = buildAdRequest(adUnitId, requestParams)
        AppOpenAd.load(
            request,
            object : AdLoadCallback<AppOpenAd> {
                override fun onAdLoaded(ad: AppOpenAd) {
                    val adId = UUID.randomUUID().toString()
                    ads[adId] = Entry(ad, System.currentTimeMillis())
                    attachEventCallbacks(adId, ad)
                    invokeOnMain {
                        result.success(mapOf("adId" to adId, "loaded" to true))
                    }
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    Log.w(TAG, "App open ad failed to load: $adError")
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
        val entry = ads[adId]
        val act = activity
        if (entry == null) {
            result.error("AD_NOT_FOUND", "No app open ad for id $adId", null)
            return
        }
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity unavailable to show app open ad.", null)
            return
        }
        if (isExpired(entry)) {
            ads.remove(adId)
            result.error("AD_EXPIRED", "App open ad expired (loaded > 4h ago).", null)
            return
        }
        if (!coordinator.tryAcquire(adId)) {
            result.error("AD_ALREADY_SHOWING", "Another full-screen ad is already showing.", null)
            return
        }
        try {
            entry.ad.show(act)
            result.success(null)
        } catch (t: Throwable) {
            coordinator.release(adId)
            ads.remove(adId)
            result.error("SHOW_FAILED", t.message, null)
        }
    }

    fun isAvailable(adId: String, result: MethodChannel.Result) {
        val entry = ads[adId]
        val available = entry != null && !isExpired(entry)
        if (entry != null && !available) {
            ads.remove(adId)
        }
        result.success(available)
    }

    fun dispose(adId: String) {
        if (coordinator.isActive(adId)) return
        val entry = ads.remove(adId) ?: return
        entry.ad.adEventCallback = null
    }

    private fun isExpired(entry: Entry): Boolean =
        System.currentTimeMillis() - entry.loadedAt >= EXPIRY_MILLIS

    private fun attachEventCallbacks(adId: String, ad: AppOpenAd) {
        ad.adEventCallback = object : AppOpenAdEventCallback {
            override fun onAdShowedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onAppOpenShowed", mapOf("adId" to adId)) }
            }

            override fun onAdDismissedFullScreenContent() {
                invokeOnMain { channel.invokeMethod("onAppOpenDismissed", mapOf("adId" to adId)) }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdFailedToShowFullScreenContent(error: FullScreenContentError) {
                Log.w(TAG, "App open ad failed to show: $error")
                invokeOnMain {
                    channel.invokeMethod(
                        "onAppOpenFailedToShow",
                        mapOf("adId" to adId) + error.toFlutterMap()
                    )
                }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdImpression() {
                invokeOnMain { channel.invokeMethod("onAppOpenImpression", mapOf("adId" to adId)) }
            }

            override fun onAdClicked() {
                invokeOnMain { channel.invokeMethod("onAppOpenClicked", mapOf("adId" to adId)) }
            }
        }
    }

    private fun invokeOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else mainHandler.post(block)
    }
}
