package io.aban.admob_nextgen.rewarded.rewarded_interstitial

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.rewarded.OnUserEarnedRewardListener
import com.google.android.libraries.ads.mobile.sdk.rewarded.RewardItem
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAdEventCallback
import io.aban.admob_nextgen.core.buildAdRequest
import io.aban.admob_nextgen.core.toFlutterMap
import io.aban.admob_nextgen.helper.FullScreenAdCoordinator
import io.flutter.plugin.common.MethodChannel
import java.util.Collections
import java.util.UUID

internal class RewardedInterstitialAdManager(
    private val channel: MethodChannel,
    private val coordinator: FullScreenAdCoordinator,
)
{

    companion object {
        private const val TAG = "RewardedInterstitial"
        private const val FORMAT = "rewarded_interstitial"
    }

    private val ads: MutableMap<String, RewardedInterstitialAd> = HashMap()
    private val rewardEarnedAdIds = Collections.synchronizedSet(mutableSetOf<String>())
    private val mainHandler = Handler(Looper.getMainLooper())

    var activity: Activity? = null

    fun load(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val request = buildAdRequest(adUnitId, requestParams)
        RewardedInterstitialAd.load(
            request,
            object : AdLoadCallback<RewardedInterstitialAd> {
                override fun onAdLoaded(ad: RewardedInterstitialAd) {
                    val adId = UUID.randomUUID().toString()
                    ads[adId] = ad
                    attachEventCallbacks(adId, ad)
                    invokeOnMain {
                        result.success(mapOf("adId" to adId, "loaded" to true))
                    }
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    Log.w(TAG, "Rewarded interstitial failed to load: $adError")
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
            result.error("AD_NOT_FOUND", "No rewarded interstitial ad for id $adId", null)
            return
        }
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is not available to show rewarded ad.", null)
            return
        }
        if (!coordinator.tryAcquire(adId)) {
            result.error("AD_ALREADY_SHOWING", "Another full-screen ad is already showing.", null)
            return
        }
        Log.d(TAG, "$FORMAT adId=$adId event=show_requested rewardEarned=false")
        try {
            ad.show(
                act,
                object : OnUserEarnedRewardListener {
                    override fun onUserEarnedReward(rewardItem: RewardItem) {
                        rewardEarnedAdIds.add(adId)
                        Log.d(TAG, "$FORMAT adId=$adId event=reward rewardEarned=true")
                        invokeOnMain {
                            channel.invokeMethod(
                                "onRewardedInterstitialUserEarnedReward",
                                mapOf(
                                    "adId" to adId,
                                    "amount" to rewardItem.amount,
                                    "type" to rewardItem.type,
                                )
                            )
                        }
                    }
                },
            )
            result.success(null)
        } catch (t: Throwable) {
            coordinator.release(adId)
            rewardEarnedAdIds.remove(adId)
            ads.remove(adId)
            result.error("SHOW_FAILED", t.message, null)
        }
    }

    fun dispose(adId: String) {
        if (coordinator.isActive(adId)) return
        val ad = ads.remove(adId) ?: return
        rewardEarnedAdIds.remove(adId)
        ad.adEventCallback = null
    }

    /** Adopts a preloaded rewarded interstitial for the standard show flow. */
    fun adopt(ad: RewardedInterstitialAd): String {
        val adId = java.util.UUID.randomUUID().toString()
        ads[adId] = ad
        rewardEarnedAdIds.remove(adId)
        attachEventCallbacks(adId, ad)
        return adId
    }

    private fun attachEventCallbacks(adId: String, ad: RewardedInterstitialAd) {
        ad.adEventCallback = object : RewardedInterstitialAdEventCallback {
            override fun onAdShowedFullScreenContent() {
                Log.d(TAG, "$FORMAT adId=$adId event=showed rewardEarned=${rewardEarnedAdIds.contains(adId)}")
                invokeOnMain { channel.invokeMethod("onRewardedInterstitialShowed", mapOf("adId" to adId)) }
            }

            override fun onAdDismissedFullScreenContent() {
                val rewardEarned = rewardEarnedAdIds.remove(adId)
                Log.d(TAG, "$FORMAT adId=$adId event=dismissed rewardEarned=$rewardEarned")
                invokeOnMain {
                    channel.invokeMethod(
                        "onRewardedInterstitialDismissed",
                        mapOf("adId" to adId, "rewardEarned" to rewardEarned)
                    )
                }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdFailedToShowFullScreenContent(error: FullScreenContentError) {
                val rewardEarned = rewardEarnedAdIds.remove(adId)
                Log.w(TAG, "$FORMAT adId=$adId event=failed_to_show code=${error.code} rewardEarned=$rewardEarned")
                invokeOnMain {
                    channel.invokeMethod(
                        "onRewardedInterstitialFailedToShow",
                        mapOf("adId" to adId, "rewardEarned" to rewardEarned) + error.toFlutterMap()
                    )
                }
                coordinator.release(adId)
                ads.remove(adId)
            }

            override fun onAdImpression() {
                Log.d(TAG, "$FORMAT adId=$adId event=impression rewardEarned=${rewardEarnedAdIds.contains(adId)}")
                invokeOnMain { channel.invokeMethod("onRewardedInterstitialImpression", mapOf("adId" to adId)) }
            }

            override fun onAdClicked() {
                Log.d(TAG, "$FORMAT adId=$adId event=clicked rewardEarned=${rewardEarnedAdIds.contains(adId)}")
                invokeOnMain { channel.invokeMethod("onRewardedInterstitialClicked", mapOf("adId" to adId)) }
            }
        }
    }

    private fun invokeOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else mainHandler.post(block)
    }
}
