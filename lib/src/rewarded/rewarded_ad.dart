import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import 'rewarded_interstitial/rewarded_interstitial_ad.dart';

/// Lifecycle callbacks fired by a [RewardedAd].
class RewardedAdListener {
  const RewardedAdListener({
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdImpression,
    this.onAdClicked,
  });

  final VoidCallback? onAdShowedFullScreenContent;
  final VoidCallback? onAdDismissedFullScreenContent;
  final void Function(AdError error)? onAdFailedToShowFullScreenContent;
  final VoidCallback? onAdImpression;
  final VoidCallback? onAdClicked;
}

/// A rewarded ad that grants [RewardItem] after the reward threshold.
class RewardedAd {
  RewardedAd._({required this.adId, required this.adUnitId});

  final String adId;
  final String adUnitId;

  RewardedAdListener? _listener;
  void Function(RewardItem reward)? _rewardListener;
  bool _disposed = false;

  set listener(RewardedAdListener? value) {
    _listener = value;
    _wireHandlers();
  }

  RewardedAdListener? get listener => _listener;

  static Future<RewardedAd> load({
    required String adUnitId,
    AdRequest? request,
  }) async {
    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>('loadRewarded', {
          'adUnitId': adUnitId,
          if (request != null) 'request': request.toMap(),
        });
    final loaded = (raw?['loaded'] as bool?) ?? false;
    if (!loaded) {
      throw AdLoadException(
        AdError.fromMap((raw?['error'] as Map?) ?? const {}),
      );
    }
    return RewardedAd._(adId: raw!['adId'] as String, adUnitId: adUnitId);
  }

  Future<void> show({
    required void Function(RewardItem reward) onUserEarnedReward,
  }) async {
    if (_disposed) {
      throw StateError('RewardedAd has already been disposed.');
    }
    _rewardListener = onUserEarnedReward;
    _wireHandlers();
    await AdsChannel.instance.channel.invokeMethod<void>('showRewarded', {
      'adId': adId,
    });
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
    await AdsChannel.instance.channel.invokeMethod<void>('disposeRewarded', {
      'adId': adId,
    });
  }

  void _wireHandlers() {
    final l = _listener;
    final r = _rewardListener;
    if (l == null && r == null) {
      AdsChannel.instance.unregister(adId);
      return;
    }
    AdsChannel.instance.register(adId, {
      'onRewardedAdShowed': (_) => l?.onAdShowedFullScreenContent?.call(),
      'onRewardedAdDismissed': (_) {
        try {
          l?.onAdDismissedFullScreenContent?.call();
        } finally {
          _markConsumed();
        }
      },
      'onRewardedAdFailedToShow': (a) {
        try {
          l?.onAdFailedToShowFullScreenContent?.call(AdError.fromMap(a));
        } finally {
          _markConsumed();
        }
      },
      'onRewardedAdImpression': (_) => l?.onAdImpression?.call(),
      'onRewardedAdClicked': (_) => l?.onAdClicked?.call(),
      'onRewardedAdUserEarnedReward': (a) => r?.call(RewardItem.fromMap(a)),
    });
  }

  void _markConsumed() {
    _disposed = true;
    AdsChannel.instance.unregister(adId);
  }
}
