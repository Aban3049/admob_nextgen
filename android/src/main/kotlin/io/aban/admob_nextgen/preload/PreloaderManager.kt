package io.aban.admob_nextgen.preload

import com.google.android.libraries.ads.mobile.sdk.common.PreloadConfiguration
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAd
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAdPreloader
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAdPreloader
import io.aban.admob_nextgen.core.buildAdRequest

/** Wraps SDK preloader pools behind the plugin method channel. */
internal object PreloaderBridge {

    fun startInterstitial(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        bufferSize: Int?,
    ): Boolean {
        val request = buildAdRequest(adUnitId, requestParams)
        val config = if (bufferSize != null) PreloadConfiguration(request, bufferSize)
        else PreloadConfiguration(request)
        return InterstitialAdPreloader.start(adUnitId, config)
    }

    fun pollInterstitial(adUnitId: String): InterstitialAd? =
        InterstitialAdPreloader.pollAd(adUnitId)

    fun isInterstitialAvailable(adUnitId: String): Boolean =
        InterstitialAdPreloader.isAdAvailable(adUnitId)

    fun interstitialCount(adUnitId: String): Int =
        InterstitialAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyInterstitial(adUnitId: String): Boolean =
        InterstitialAdPreloader.destroy(adUnitId)

    fun startRewarded(
        adUnitId: String,
        requestParams: Map<String, Any?>?,
        bufferSize: Int?,
    ): Boolean {
        val request = buildAdRequest(adUnitId, requestParams)
        val config = if (bufferSize != null) PreloadConfiguration(request, bufferSize)
        else PreloadConfiguration(request)
        return RewardedInterstitialAdPreloader.start(adUnitId, config)
    }

    fun pollRewarded(adUnitId: String): RewardedInterstitialAd? =
        RewardedInterstitialAdPreloader.pollAd(adUnitId)

    fun isRewardedAvailable(adUnitId: String): Boolean =
        RewardedInterstitialAdPreloader.isAdAvailable(adUnitId)

    fun rewardedCount(adUnitId: String): Int =
        RewardedInterstitialAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyRewarded(adUnitId: String): Boolean =
        RewardedInterstitialAdPreloader.destroy(adUnitId)
}
