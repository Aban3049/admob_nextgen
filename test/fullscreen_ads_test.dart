import 'dart:async';

import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('next_gen_sdk');
const _codec = StandardMethodCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test(
    'InterstitialAd.load returns ad and reports structured failure',
    () async {
      var succeeds = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (_) async {
            if (succeeds) return {'loaded': true, 'adId': 'interstitial-1'};
            return {
              'loaded': false,
              'error': {'code': 3, 'message': 'No fill'},
            };
          });

      final ad = await InterstitialAd.load(adUnitId: 'unit');
      expect(ad.adId, 'interstitial-1');

      succeeds = false;
      await expectLater(
        InterstitialAd.load(adUnitId: 'unit'),
        throwsA(
          isA<AdLoadException>()
              .having((e) => e.error.code, 'code', 3)
              .having((e) => e.error.message, 'message', 'No fill'),
        ),
      );
    },
  );

  test(
    'InterstitialAd routes lifecycle callbacks and consumes on dismissal',
    () async {
      _mockLoadedAd('interstitial-2');
      final events = <String>[];
      final ad = await InterstitialAd.load(adUnitId: 'unit');
      ad.listener = InterstitialAdListener(
        onAdShowedFullScreenContent: () => events.add('showed'),
        onAdImpression: () => events.add('impression'),
        onAdClicked: () => events.add('clicked'),
        onAdDismissedFullScreenContent: () => events.add('dismissed'),
      );

      await _dispatch('onInterstitialShowed', ad.adId);
      await _dispatch('onInterstitialImpression', ad.adId);
      await _dispatch('onInterstitialClicked', ad.adId);
      await _dispatch('onInterstitialDismissed', ad.adId);

      expect(events, ['showed', 'impression', 'clicked', 'dismissed']);
      await expectLater(ad.show(), throwsStateError);
    },
  );

  test('InterstitialAd consumes terminal event without a listener', () async {
    _mockLoadedAd('interstitial-no-listener');
    final ad = await InterstitialAd.load(adUnitId: 'unit');

    await _dispatch('onInterstitialDismissed', ad.adId);

    await expectLater(ad.show(), throwsStateError);
  });

  test('InterstitialAd cleans up when terminal listener throws', () async {
    _mockLoadedAd('interstitial-throw');
    final ad = await InterstitialAd.load(adUnitId: 'unit');
    ad.listener = InterstitialAdListener(
      onAdDismissedFullScreenContent: () => throw StateError('callback failed'),
    );

    await _dispatch('onInterstitialDismissed', ad.adId);
    await expectLater(ad.show(), throwsStateError);
  });

  test(
    'InterstitialAd prevents duplicate show while first show is active',
    () async {
      final showCompleter = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            if (call.method == 'loadInterstitial') {
              return {'loaded': true, 'adId': 'interstitial-showing'};
            }
            if (call.method == 'showInterstitial') {
              await showCompleter.future;
              return null;
            }
            return null;
          });
      final ad = await InterstitialAd.load(adUnitId: 'unit');

      final firstShow = ad.show();
      await expectLater(ad.show(), throwsStateError);
      showCompleter.complete();
      await firstShow;
    },
  );

  test('recoverable InterstitialAd show channel error allows retry', () async {
    var showCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          if (call.method == 'loadInterstitial') {
            return {'loaded': true, 'adId': 'interstitial-retry'};
          }
          if (call.method == 'showInterstitial' && showCalls++ == 0) {
            throw PlatformException(code: 'NO_ACTIVITY');
          }
          return null;
        });
    final ad = await InterstitialAd.load(adUnitId: 'unit');

    await expectLater(ad.show(), throwsA(isA<PlatformException>()));
    await ad.show();
    expect(showCalls, 2);
  });

  test('AppOpenAd routes failed-to-show and consumes the ad', () async {
    _mockLoadedAd('app-open-1', method: 'loadAppOpen');
    AdError? error;
    final ad = await AppOpenAd.load(adUnitId: 'unit');
    ad.listener = AppOpenAdListener(
      onAdFailedToShowFullScreenContent: (value) => error = value,
    );

    await _dispatch('onAppOpenFailedToShow', ad.adId, {
      'code': 7,
      'message': 'Presentation failed',
    });

    expect(error?.code, 7);
    await expectLater(ad.show(), throwsStateError);
  });

  test('AppOpenAd.load returns ad and reports structured failure', () async {
    var succeeds = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
          if (succeeds) return {'loaded': true, 'adId': 'app-open-load'};
          return {
            'loaded': false,
            'error': {'code': 2, 'message': 'Network error'},
          };
        });

    final ad = await AppOpenAd.load(adUnitId: 'unit');
    expect(ad.adId, 'app-open-load');

    succeeds = false;
    await expectLater(
      AppOpenAd.load(adUnitId: 'unit'),
      throwsA(
        isA<AdLoadException>()
            .having((e) => e.error.code, 'code', 2)
            .having((e) => e.error.message, 'message', 'Network error'),
      ),
    );
  });

  test('AppOpenAd consumes failed-to-show without a listener', () async {
    _mockLoadedAd('app-open-no-listener', method: 'loadAppOpen');
    final ad = await AppOpenAd.load(adUnitId: 'unit');

    await _dispatch('onAppOpenFailedToShow', ad.adId, {
      'code': 7,
      'message': 'Presentation failed',
    });

    expect(await ad.isAvailable(), isFalse);
    await expectLater(ad.show(), throwsStateError);
  });

  test(
    'AppOpenAd prevents duplicate show while first show is active',
    () async {
      final showCompleter = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            if (call.method == 'loadAppOpen') {
              return {'loaded': true, 'adId': 'app-open-showing'};
            }
            if (call.method == 'showAppOpen') {
              await showCompleter.future;
              return null;
            }
            return null;
          });
      final ad = await AppOpenAd.load(adUnitId: 'unit');

      final firstShow = ad.show();
      await expectLater(ad.show(), throwsStateError);
      showCompleter.complete();
      await firstShow;
    },
  );

  test(
    'stale terminal callback does not affect a newer interstitial',
    () async {
      var loadCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            if (call.method == 'loadInterstitial') {
              loadCount++;
              return {'loaded': true, 'adId': 'interstitial-$loadCount'};
            }
            return null;
          });

      final oldAd = await InterstitialAd.load(adUnitId: 'unit');
      final newAd = await InterstitialAd.load(adUnitId: 'unit');
      var newDismissals = 0;
      newAd.listener = InterstitialAdListener(
        onAdDismissedFullScreenContent: () => newDismissals++,
      );

      await _dispatch('onInterstitialDismissed', oldAd.adId);

      expect(newDismissals, 0);
      await newAd.show();
    },
  );
}

void _mockLoadedAd(String adId, {String method = 'loadInterstitial'}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (call) async {
        if (call.method == method) return {'loaded': true, 'adId': adId};
        return null;
      });
}

Future<void> _dispatch(
  String method,
  String adId, [
  Map<String, Object?> extra = const {},
]) async {
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'next_gen_sdk',
        _codec.encodeMethodCall(MethodCall(method, {'adId': adId, ...extra})),
        (_) {},
      );
}
