import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';

/// Lifecycle callbacks fired by an [AppOpenAd].
class AppOpenAdListener {
  const AppOpenAdListener({
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

/// Full-screen ad shown when the user opens (or returns to) the app.
///
/// App open ads expire 4 hours after they are loaded; use [isAvailable] to
/// check before calling [show]. Typical usage is to keep one loaded and
/// trigger [show] when `AppStateEventNotifier.appStateStream` reports that the
/// app returned to the foreground.
class AppOpenAd {
  AppOpenAd._({required this.adId, required this.adUnitId}) {
    _wireHandlers();
  }

  final String adId;
  final String adUnitId;

  /// Optional lifecycle callbacks. May be replaced or cleared before [show].
  AppOpenAdListener? listener;
  bool _disposed = false;
  bool _showing = false;

  void _wireHandlers() {
    AdsChannel.instance.register(adId, {
      'onAppOpenShowed': (_) => listener?.onAdShowedFullScreenContent?.call(),
      'onAppOpenDismissed': (_) {
        try {
          listener?.onAdDismissedFullScreenContent?.call();
        } finally {
          _markConsumed();
        }
      },
      'onAppOpenFailedToShow': (a) {
        try {
          listener?.onAdFailedToShowFullScreenContent?.call(AdError.fromMap(a));
        } finally {
          _markConsumed();
        }
      },
      'onAppOpenImpression': (_) => listener?.onAdImpression?.call(),
      'onAppOpenClicked': (_) => listener?.onAdClicked?.call(),
    });
  }

  /// Load a single app open ad. Sample test unit:
  /// `ca-app-pub-3940256099942544/9257395921`.
  ///
  /// Pass an [AdRequest] to attach targeting (keywords, contentUrl, etc.).
  /// Returns the loaded ad. Throws [AdLoadException] on failure.
  static Future<AppOpenAd> load({
    required String adUnitId,
    AdRequest? request,
  }) async {
    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>('loadAppOpen', {
          'adUnitId': adUnitId,
          if (request != null) 'request': request.toMap(),
        });
    final loaded = (raw?['loaded'] as bool?) ?? false;
    if (!loaded) {
      throw AdLoadException(
        AdError.fromMap((raw?['error'] as Map?) ?? const {}),
      );
    }
    return AppOpenAd._(adId: raw!['adId'] as String, adUnitId: adUnitId);
  }

  /// Returns false if the ad has been consumed, never loaded, or expired
  /// (> 4 hours since load).
  Future<bool> isAvailable() async {
    if (_disposed) return false;
    final raw = await AdsChannel.instance.channel.invokeMethod<bool>(
      'isAppOpenAvailable',
      {'adId': adId},
    );
    return raw ?? false;
  }

  /// Show the ad. Throws [StateError] if it has already been shown or
  /// disposed.
  Future<void> show() async {
    if (_disposed) {
      throw StateError('AppOpenAd has already been consumed or disposed.');
    }
    if (_showing) {
      throw StateError('AppOpenAd is already showing.');
    }
    _showing = true;
    try {
      await AdsChannel.instance.channel.invokeMethod<void>('showAppOpen', {
        'adId': adId,
      });
    } catch (_) {
      _showing = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
    await AdsChannel.instance.channel.invokeMethod<void>('disposeAppOpen', {
      'adId': adId,
    });
  }

  void _markConsumed() {
    _disposed = true;
    _showing = false;
    AdsChannel.instance.unregister(adId);
  }
}
