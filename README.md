# admob_nextgen

Beta Flutter plugin for the Android Google Mobile Ads Next-Gen SDK.

`admob_nextgen` provides Android-only wrappers for initialization, UMP consent,
banner ads, interstitial ads, rewarded ads, rewarded interstitial ads, app open
ads, preloaders, and customizable native ad templates.

Beta note: this package targets Android only. iOS is not implemented yet.

This is an unofficial Flutter plugin. It is not published, endorsed, or
maintained by Google.

## Known SDK issue

Google's GMA Next-Gen SDK release notes say version `1.1.1` fixes an issue
where rewarded ad pods could freeze during transitions and prevent users from
closing the ad:

https://developers.google.com/admob/android/next-gen/rel-notes

There is also a public AdMob Community thread with a reported Next-Gen SDK
`NullPointerException` crash and stack trace:

https://support.google.com/admob/thread/438640611/admob-next-gen-1-1-0-fatal-exception-java-lang-nullpointerexception?hl=en

Until that native SDK crash situation is clear, this package is not bumping the
bundled `ads-mobile-sdk` dependency to `1.1.1`.

## Demo

![Banner Ad](https://raw.githubusercontent.com/Aban3049/admob_nextgen/main/screenshots/banner.webp)
![Native Ad](https://raw.githubusercontent.com/Aban3049/admob_nextgen/main/screenshots/native.webp)


## Features

- Google Mobile Ads Next-Gen SDK initialization.
- UMP consent flow helpers.
- Banner ads with anchored, large anchored, and inline adaptive sizes.
- Interstitial, rewarded, rewarded interstitial, and app open ads.
- Interstitial and rewarded interstitial preloaders.
- Standard native ads with three prebuilt Android templates:
  - `NativeBannerAdView`
  - `NativeSmallAdView`
  - `NativeLargeAdView`
- Native ad styling for card color, CTA button, title, description, and ad badge.


## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  admob_nextgen: ^0.1.0-beta.2
```

Then run:

```bash
flutter pub get
```

## Android setup

Add your AdMob app ID to `android/app/src/main/AndroidManifest.xml` inside the
`<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" />
```

The example test app ID is:

```xml
ca-app-pub-3940256099942544~3347511713
```

Use AdMob test ad unit IDs while developing. Do not use live ad units for local
testing.

## Initialize ads and consent

Important: unlike the old Google Mobile Ads Flutter SDK flow, this package
requires the Google Mobile Ads Next-Gen SDK to be initialized before loading or
showing ads. Call `MobileAds.initialize()` after consent allows ad requests.

```dart
import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConsentInformation.instance.requestConsentInfoUpdate(
    const ConsentRequestParameters(),
  );

  await ConsentForm.loadAndShowConsentFormIfRequired();

  if (await ConsentInformation.instance.canRequestAds()) {
    await MobileAds.initialize();
  }

  runApp(const MyApp());
}
```

Optionally configure test devices:

```dart
await MobileAds.setRequestConfiguration(
  const RequestConfiguration(
    testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
  ),
);
```

## Banner ad

```dart
BannerAdView(
  adUnitId: 'ca-app-pub-3940256099942544/9214589741',
  size: const AdSize.largeAnchored(),
  height: 120,
)
```

Available banner sizes:

- `AdSize.anchored()`
- `AdSize.largeAnchored()`
- `AdSize.inline()`

## Interstitial ad

```dart
final ad = await InterstitialAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
);

ad.listener = InterstitialAdListener(
  onAdDismissedFullScreenContent: () {
    ad.dispose();
  },
);

await ad.show();
```

## Rewarded ad

```dart
final ad = await RewardedAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/5224354917',
);

await ad.show(
  onUserEarnedReward: (reward) {
    print('Reward: ${reward.amount} ${reward.type}');
  },
);
```

## Rewarded interstitial ad

```dart
final ad = await RewardedInterstitialAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/5354046379',
);

await ad.show(
  onUserEarnedReward: (reward) {
    print('Reward: ${reward.amount} ${reward.type}');
  },
);
```

## App open ad

Load an app open ad, then show it when the app returns to the foreground:

```dart
AppOpenAd? appOpenAd;

Future<void> loadAppOpenAd() async {
  appOpenAd = await AppOpenAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/9257395921',
  );
}

Future<void> showAppOpenAdIfAvailable() async {
  final ad = appOpenAd;
  if (ad == null || !await ad.isAvailable()) return;

  appOpenAd = null;
  await ad.show();
}
```

## Native ads

Load one `NativeAd`, then render it with one of the three prebuilt templates.
Native ads should be disposed when the placement is no longer used.

```dart
final nativeAd = NativeAd(
  adUnitId: 'ca-app-pub-3940256099942544/2247696110',
);

await nativeAd.load();
```

### Native banner template

Smallest template with icon, title, and CTA button.

```dart
NativeBannerAdView(
  nativeAd: nativeAd,
)
```

### Native small template

Compact template with icon, title, description, and CTA button.

```dart
NativeSmallAdView(
  nativeAd: nativeAd,
)
```

### Native large template

Large template with icon, title, description, media content, and CTA button.

```dart
NativeLargeAdView(
  nativeAd: nativeAd,
  height: 380,
)
```

If you increase the CTA button height, also increase the native view height:

```dart
NativeLargeAdView(
  nativeAd: nativeAd,
  height: 430,
  style: const NativeAdViewStyle(
    callToActionHeight: 70,
  ),
)
```

## Native customization options

All styling options are optional:

```dart
NativeLargeAdView(
  nativeAd: nativeAd,
  height: 430,
  style: const NativeAdViewStyle(
    cardColor: Colors.white,
    titleColor: Color(0xFF101828),
    descriptionColor: Color(0xFF475467),
    callToActionText: 'Install',
    callToActionColor: Color(0xFF1E93E8),
    callToActionTextColor: Colors.white,
    callToActionHeight: 50,
    callToActionCornerRadius: 14,
    adBadgeText: 'Sponsored',
    adBadgeTextColor: Color(0xFF1E93E8),
    adBadgeColor: Colors.white,
    adBadgeBorderColor: Color(0xFF1E93E8),
    adBadgeBorderWidth: 1,
    adBadgeCornerRadius: 6,
  ),
)
```

Supported `NativeAdViewStyle` fields:

- `cardColor`
- `titleColor`
- `descriptionColor`
- `callToActionText`
- `callToActionColor`
- `callToActionTextColor`
- `callToActionHeight`
- `callToActionCornerRadius`
- `adBadgeText`
- `adBadgeTextColor`
- `adBadgeColor`
- `adBadgeBorderColor`
- `adBadgeBorderWidth`
- `adBadgeCornerRadius`

## Preloaders

Interstitial and rewarded interstitial ads can be preloaded:

```dart
await InterstitialAdPreloader.start(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
  bufferSize: 2,
);

final ad = await InterstitialAdPreloader.poll(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
);

await ad?.show();
```

## Request targeting

Pass optional request hints to supported ad loads:

```dart
const request = AdRequest(
  keywords: ['games', 'flutter'],
  contentUrl: 'https://example.com/article',
  customTargeting: {
    'placement': ['home'],
  },
);

final ad = await InterstitialAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
  request: request,
);
```
