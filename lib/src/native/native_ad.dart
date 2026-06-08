import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';

/// Optional configuration for standard native ad requests.
class NativeAdOptions {
  const NativeAdOptions({this.startVideoMuted = true});

  /// Whether native video creatives should start muted.
  final bool startVideoMuted;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'startVideoMuted': startVideoMuted,
  };
}

/// Lifecycle callbacks fired by a [NativeAd].
class NativeAdListener {
  const NativeAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdImpression,
    this.onAdClicked,
  });

  final void Function(NativeAd ad)? onAdLoaded;
  final void Function(NativeAd ad, AdError error)? onAdFailedToLoad;
  final void Function(NativeAd ad)? onAdShowedFullScreenContent;
  final void Function(NativeAd ad)? onAdDismissedFullScreenContent;
  final void Function(NativeAd ad, AdError error)?
  onAdFailedToShowFullScreenContent;
  final void Function(NativeAd ad)? onAdImpression;
  final void Function(NativeAd ad)? onAdClicked;
}

/// A standard native ad loaded by the GMA Next-Gen SDK.
///
/// Create an instance, call [load], render it with [NativeAdView], and call
/// [dispose] when the placement is no longer used.
class NativeAd {
  NativeAd({
    required this.adUnitId,
    this.listener,
    this.request,
    this.options = const NativeAdOptions(),
  });

  /// AdMob native ad unit ID. For testing use
  /// `ca-app-pub-3940256099942544/2247696110`.
  final String adUnitId;

  /// Optional callbacks for load and lifecycle events.
  final NativeAdListener? listener;

  /// Optional targeting hints.
  final AdRequest? request;

  /// Optional native request configuration.
  final NativeAdOptions options;

  String? _adId;
  bool _disposed = false;

  /// Internal identifier for the loaded Android native ad.
  String? get adId => _adId;

  /// True after [load] succeeds and before [dispose] is called.
  bool get isLoaded => _adId != null && !_disposed;

  /// True after [dispose] has been called.
  bool get isDisposed => _disposed;

  /// Load this native ad. Throws [AdLoadException] if the SDK reports a load
  /// failure.
  Future<void> load() async {
    if (_disposed) {
      throw StateError('NativeAd has already been disposed.');
    }
    if (_adId != null) {
      throw StateError('NativeAd has already been loaded.');
    }

    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>('loadNativeAd', {
          'adUnitId': adUnitId,
          if (request != null) 'request': request!.toMap(),
          'options': options.toMap(),
        });

    final loaded = (raw?['loaded'] as bool?) ?? false;
    if (!loaded) {
      final error = AdError.fromMap((raw?['error'] as Map?) ?? const {});
      listener?.onAdFailedToLoad?.call(this, error);
      throw AdLoadException(error);
    }

    _adId = raw!['adId'] as String;
    _wireHandlers();
    listener?.onAdLoaded?.call(this);
  }

  /// Release native references to this ad.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final id = _adId;
    if (id == null) return;
    AdsChannel.instance.unregister(id);
    await AdsChannel.instance.channel.invokeMethod<void>('disposeNativeAd', {
      'adId': id,
    });
  }

  void _wireHandlers() {
    final id = _adId;
    final l = listener;
    if (id == null || l == null) return;
    AdsChannel.instance.register(id, {
      'onNativeShowed': (_) => l.onAdShowedFullScreenContent?.call(this),
      'onNativeDismissed': (_) => l.onAdDismissedFullScreenContent?.call(this),
      'onNativeFailedToShow': (a) =>
          l.onAdFailedToShowFullScreenContent?.call(this, AdError.fromMap(a)),
      'onNativeImpression': (_) => l.onAdImpression?.call(this),
      'onNativeClicked': (_) => l.onAdClicked?.call(this),
    });
  }
}

/// Available Android native ad template layouts.
enum NativeAdTemplate {
  /// Compact icon + headline + call-to-action layout.
  banner('next_gen_sdk/native_banner', 92),

  /// Icon + headline + description + call-to-action layout.
  small('next_gen_sdk/native_small', 150),

  /// Full native layout with media content.
  large('next_gen_sdk/native_large', 380);

  const NativeAdTemplate(this.viewType, this.defaultHeight);

  /// Android platform view type registered by the plugin.
  final String viewType;

  /// Suggested height for this template.
  final double defaultHeight;
}

/// Optional styling for Android native ad templates.
class NativeAdViewStyle {
  const NativeAdViewStyle({
    this.cardColor,
    this.callToActionColor,
    this.callToActionTextColor,
    this.callToActionText,
    this.callToActionHeight,
    this.callToActionCornerRadius,
    this.titleColor,
    this.descriptionColor,
    this.adBadgeText,
    this.adBadgeTextColor,
    this.adBadgeColor,
    this.adBadgeBorderColor,
    this.adBadgeBorderWidth,
    this.adBadgeCornerRadius,
  });

  /// Background color for the native ad card.
  final Color? cardColor;

  /// Background color for the call-to-action button.
  final Color? callToActionColor;

  /// Text color for the call-to-action button.
  final Color? callToActionTextColor;

  /// Optional override for the call-to-action button text.
  final String? callToActionText;

  /// Optional call-to-action button height in logical pixels.
  final double? callToActionHeight;

  /// Optional call-to-action button corner radius in logical pixels.
  final double? callToActionCornerRadius;

  /// Optional headline/title text color.
  final Color? titleColor;

  /// Optional description/body text color.
  final Color? descriptionColor;

  /// Optional override for the small ad badge text. Defaults to `Ad`.
  final String? adBadgeText;

  /// Optional ad badge text color.
  final Color? adBadgeTextColor;

  /// Optional ad badge background color.
  final Color? adBadgeColor;

  /// Optional ad badge border color.
  final Color? adBadgeBorderColor;

  /// Optional ad badge border width in logical pixels.
  final double? adBadgeBorderWidth;

  /// Optional ad badge corner radius in logical pixels.
  final double? adBadgeCornerRadius;

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (cardColor != null) 'cardColor': cardColor!.toARGB32(),
    if (callToActionColor != null)
      'callToActionColor': callToActionColor!.toARGB32(),
    if (callToActionTextColor != null)
      'callToActionTextColor': callToActionTextColor!.toARGB32(),
    if (callToActionText != null) 'callToActionText': callToActionText,
    if (callToActionHeight != null) 'callToActionHeight': callToActionHeight,
    if (callToActionCornerRadius != null)
      'callToActionCornerRadius': callToActionCornerRadius,
    if (titleColor != null) 'titleColor': titleColor!.toARGB32(),
    if (descriptionColor != null)
      'descriptionColor': descriptionColor!.toARGB32(),
    if (adBadgeText != null) 'adBadgeText': adBadgeText,
    if (adBadgeTextColor != null)
      'adBadgeTextColor': adBadgeTextColor!.toARGB32(),
    if (adBadgeColor != null) 'adBadgeColor': adBadgeColor!.toARGB32(),
    if (adBadgeBorderColor != null)
      'adBadgeBorderColor': adBadgeBorderColor!.toARGB32(),
    if (adBadgeBorderWidth != null) 'adBadgeBorderWidth': adBadgeBorderWidth,
    if (adBadgeCornerRadius != null) 'adBadgeCornerRadius': adBadgeCornerRadius,
  };
}

/// Widget that renders a loaded [NativeAd]. Defaults to the large template.
class NativeAdView extends StatelessWidget {
  const NativeAdView({
    super.key,
    required this.nativeAd,
    this.height,
    this.placeholder,
    this.template = NativeAdTemplate.large,
    this.style,
  });

  /// Loaded native ad to display.
  final NativeAd nativeAd;

  /// Optional explicit height for the Android view.
  final double? height;

  /// Optional widget shown on non-Android platforms or before the ad is loaded.
  final Widget? placeholder;

  /// Android native template to render.
  final NativeAdTemplate template;

  /// Optional Android native template styling.
  final NativeAdViewStyle? style;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid || !nativeAd.isLoaded) {
      return placeholder ?? const SizedBox.shrink();
    }

    final id = nativeAd.adId;
    if (id == null) {
      return placeholder ?? const SizedBox.shrink();
    }

    return _NativeAdPlatformView(
      nativeAd: nativeAd,
      viewType: template.viewType,
      height: height ?? template.defaultHeight,
      style: style,
    );
  }
}

/// Smallest native template: icon, headline, and call-to-action.
class NativeBannerAdView extends StatelessWidget {
  const NativeBannerAdView({
    super.key,
    required this.nativeAd,
    this.height,
    this.placeholder,
    this.style,
  });

  final NativeAd nativeAd;
  final double? height;
  final Widget? placeholder;
  final NativeAdViewStyle? style;

  @override
  Widget build(BuildContext context) => NativeAdView(
    nativeAd: nativeAd,
    height: height,
    placeholder: placeholder,
    template: NativeAdTemplate.banner,
    style: style,
  );
}

/// Native template with icon, headline, description, and call-to-action.
class NativeSmallAdView extends StatelessWidget {
  const NativeSmallAdView({
    super.key,
    required this.nativeAd,
    this.height,
    this.placeholder,
    this.style,
  });

  final NativeAd nativeAd;
  final double? height;
  final Widget? placeholder;
  final NativeAdViewStyle? style;

  @override
  Widget build(BuildContext context) => NativeAdView(
    nativeAd: nativeAd,
    height: height,
    placeholder: placeholder,
    template: NativeAdTemplate.small,
    style: style,
  );
}

/// Largest native template with media content.
class NativeLargeAdView extends StatelessWidget {
  const NativeLargeAdView({
    super.key,
    required this.nativeAd,
    this.height,
    this.placeholder,
    this.style,
  });

  final NativeAd nativeAd;
  final double? height;
  final Widget? placeholder;
  final NativeAdViewStyle? style;

  @override
  Widget build(BuildContext context) => NativeAdView(
    nativeAd: nativeAd,
    height: height,
    placeholder: placeholder,
    template: NativeAdTemplate.large,
    style: style,
  );
}

class _NativeAdPlatformView extends StatelessWidget {
  const _NativeAdPlatformView({
    required this.nativeAd,
    required this.viewType,
    required this.height,
    this.style,
  });

  final NativeAd nativeAd;
  final String viewType;
  final double height;
  final NativeAdViewStyle? style;

  @override
  Widget build(BuildContext context) {
    final id = nativeAd.adId;
    if (id == null) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: AndroidView(
        key: ValueKey<String>('$viewType:$id'),
        viewType: viewType,
        creationParams: <String, dynamic>{
          'adId': id,
          if (style != null) ...style!.toMap(),
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
