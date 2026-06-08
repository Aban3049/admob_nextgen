/// Flutter wrapper around the Google Mobile Ads (GMA) Next-Gen SDK 1.0+.
///
/// **Android only.** For iOS, combine this package with `google_mobile_ads`.
///
/// Provides idiomatic Dart access to:
///
/// * [MobileAds] — SDK initialization, version, [RequestConfiguration]
/// * [BannerAdView] — inline banner ads (adaptive anchored / large anchored / inline)
/// * [InterstitialAd] — full-screen interstitial ads
/// * [RewardedAd], [RewardedInterstitialAd] — rewarded full-screen ads
/// * [AppOpenAd] — full-screen ads with 4-hour expiry, for foreground transitions
/// * [ConsentInformation], [ConsentForm] — UMP consent flow helpers
/// * [NativeAd], [NativeAdView] — standard native ad loading and rendering
/// * [InterstitialAdPreloader], [RewardedInterstitialAdPreloader] — pool-based
///   preloading for instant ad display (Next-Gen SDK exclusive)
/// * [AdRequest] — targeting hints (keywords, contentUrl, customTargeting)
library;

export 'src/banner/ad_size.dart';
export 'src/banner/banner_ad.dart';
export 'src/consent/consent.dart';
export 'src/core/ad_error.dart';
export 'src/core/ad_request.dart';
export 'src/core/mobile_ads.dart';
export 'src/core/request_configuration.dart' hide applyRequestConfiguration;
export 'src/app_open/app_open_ad.dart';
export 'src/interstitial/interstitial_ad.dart';
export 'src/rewarded/rewarded_ad.dart';
export 'src/rewarded/rewarded_Interstitial/rewarded_interstitial_ad.dart';
export 'src/native/native_ad.dart';
export 'src/preload/preloader.dart';
