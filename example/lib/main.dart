import 'dart:async';

import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/material.dart';

class AdTestIds {
  const AdTestIds._();

  static const banner = 'ca-app-pub-3940256099942544/9214589741';
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const rewardedInterstitial = 'ca-app-pub-3940256099942544/5354046379';
  static const appOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const native = 'ca-app-pub-3940256099942544/2247696110';
}

class NativeDemoStyles {
  const NativeDemoStyles._();

  static const banner = NativeAdViewStyle(
    cardColor: Color(0xFFFFFFFF),
    callToActionColor: Color(0xFF0B9730),
    callToActionTextColor: Colors.white,
    callToActionText: 'Open',
    callToActionHeight: 40,
    callToActionCornerRadius: 10,
    titleColor: Color(0xFF111111),
    adBadgeTextColor: Color(0xFF0B9730),
    adBadgeBorderColor: Color(0xFF0B9730),
  );

  static const small = NativeAdViewStyle(
    cardColor: Color(0xFFF7FFF9),
    callToActionColor: Color(0xFF0B9730),
    callToActionTextColor: Colors.white,
    callToActionText: 'Install',
    callToActionHeight: 40,
    callToActionCornerRadius: 12,
    titleColor: Color(0xFF101828),
    descriptionColor: Color(0xFF667085),
    adBadgeText: 'Ad',
    adBadgeTextColor: Color(0xFF0B9730),
    adBadgeColor: Color(0xFFFFFFFF),
    adBadgeBorderColor: Color(0xFF0B9730),
    adBadgeCornerRadius: 6,
  );

  static const large = NativeAdViewStyle(
    cardColor: Color(0xFFFFFFFF),
    callToActionColor: Color(0xFF1E93E8),
    callToActionTextColor: Colors.white,
    callToActionText: 'Install',
    callToActionHeight: 40,
    callToActionCornerRadius: 14,
    titleColor: Color(0xFF101828),
    descriptionColor: Color(0xFF475467),
    adBadgeText: 'Sponsored',
    adBadgeTextColor: Color(0xFF1E93E8),
    adBadgeColor: Color(0xFFFFFFFF),
    adBadgeBorderColor: Color(0xFF1E93E8),
    adBadgeBorderWidth: 1,
    adBadgeCornerRadius: 6,
  );
}

ThemeData buildDemoTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D5AFE),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Georgia',
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        fontSize: 11,
      ),
      bodyLarge: TextStyle(fontSize: 14, height: 1.5),
      bodyMedium: TextStyle(fontSize: 13, height: 1.4),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.4,
        color: Color(0xFF1A1A2E),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        elevation: 2,
        shadowColor: const Color(0x443D5AFE),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        side: const BorderSide(color: Color(0xFF3D5AFE), width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF8F9FF),
      surfaceTintColor: const Color(0xFF3D5AFE),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F5FA),
  );
}

class DemoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DemoAppBar({super.key, required this.adsReady});

  final bool adsReady;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0x14000000)),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.ads_click_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Next Gen Ads',
        style: textTheme.titleLarge?.copyWith(color: const Color(0xFF1A1A2E)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AdsReadyChip(adsReady: adsReady),
        ),
      ],
    );
  }
}

class AdsReadyChip extends StatelessWidget {
  const AdsReadyChip({super.key, required this.adsReady});

  final bool adsReady;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = adsReady
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final borderColor = adsReady
        ? const Color(0xFF81C784)
        : const Color(0xFFFFB74D);
    final foregroundColor = adsReady
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: adsReady
                  ? const Color(0xFF43A047)
                  : const Color(0xFFFB8C00),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            adsReady ? 'Live' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context, status);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon(status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacySection extends StatelessWidget {
  const PrivacySection({super.key, required this.onShowPrivacyOptions});

  final VoidCallback onShowPrivacyOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(label: 'CONSENT'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onShowPrivacyOptions,
          icon: const Icon(Icons.shield_outlined, size: 18),
          label: const Text('Privacy Options'),
        ),
      ],
    );
  }
}

class FullScreenAdsSection extends StatelessWidget {
  const FullScreenAdsSection({
    super.key,
    required this.adsReady,
    required this.isShowingAd,
    required this.onShowInterstitial,
    required this.onShowRewarded,
    required this.onShowRewardedInterstitial,
    required this.onShowAppOpen,
  });

  final bool adsReady;
  final bool isShowingAd;
  final VoidCallback onShowInterstitial;
  final VoidCallback onShowRewarded;
  final VoidCallback onShowRewardedInterstitial;
  final VoidCallback onShowAppOpen;

  @override
  Widget build(BuildContext context) {
    final enabled = adsReady && !isShowingAd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(label: 'FULL-SCREEN ADS'),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: enabled ? onShowInterstitial : null,
          icon: const Icon(Icons.fullscreen_rounded, size: 20),
          label: const Text('Show Interstitial (preloaded)'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: enabled ? onShowRewarded : null,
          icon: const Icon(Icons.star_rounded, size: 20),
          label: const Text('Show Rewarded'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: enabled ? onShowRewardedInterstitial : null,
          icon: const Icon(Icons.star_border_purple500_rounded, size: 20),
          label: const Text('Show Rewarded Interstitial'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: enabled ? onShowAppOpen : null,
          icon: const Icon(Icons.launch_rounded, size: 20),
          label: const Text('Show App Open Ad (if loaded)'),
        ),
      ],
    );
  }
}

class NativeAdsSection extends StatelessWidget {
  const NativeAdsSection({
    super.key,
    required this.adsReady,
    required this.isLoading,
    required this.onLoadNativeAds,
    required this.bannerAd,
    required this.smallAd,
    required this.largeAd,
  });

  final bool adsReady;
  final bool isLoading;
  final VoidCallback onLoadNativeAds;
  final NativeAd? bannerAd;
  final NativeAd? smallAd;
  final NativeAd? largeAd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(label: 'NATIVE ADS'),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: adsReady && !isLoading ? onLoadNativeAds : null,
          icon: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                )
              : const Icon(Icons.photo_library_outlined, size: 20),
          label: Text(isLoading ? 'Loading Native...' : 'Load Native Ads'),
        ),
        const SizedBox(height: 20),
        if (bannerAd != null) ...[
          NativeAdCard(
            label: 'Native Banner',
            icon: Icons.view_stream_rounded,
            child: NativeBannerAdView(
              nativeAd: bannerAd!,
              style: NativeDemoStyles.banner,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (smallAd != null) ...[
          NativeAdCard(
            label: 'Native Small',
            icon: Icons.view_compact_rounded,
            child: NativeSmallAdView(
              nativeAd: smallAd!,
              style: NativeDemoStyles.small,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (largeAd != null) ...[
          NativeAdCard(
            label: 'Native Large',
            icon: Icons.view_agenda_rounded,
            child: NativeLargeAdView(
              nativeAd: largeAd!,
              style: NativeDemoStyles.large,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class BottomBannerAd extends StatelessWidget {
  const BottomBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x18000000))),
      ),
      child: const BannerAdView(
        adUnitId: AdTestIds.banner,
        size: AdSize.largeAnchored(),
        height: 120,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(thickness: 1, color: color.withValues(alpha: 0.12)),
        ),
      ],
    );
  }
}

class NativeAdCard extends StatelessWidget {
  const NativeAdCard({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

IconData statusIcon(String status) {
  final s = status.toLowerCase();
  if (s.contains('fail') || s.contains('error') || s.contains('cannot')) {
    return Icons.error_outline_rounded;
  }
  if (s.contains('load') || s.contains('showing') || s.contains('loading')) {
    return Icons.hourglass_top_rounded;
  }
  if (s.contains('reward') ||
      s.contains('dismiss') ||
      s.contains('loaded') ||
      s.contains('ready') ||
      s.contains('closed')) {
    return Icons.check_circle_outline_rounded;
  }
  return Icons.info_outline_rounded;
}

Color statusColor(BuildContext context, String status) {
  final s = status.toLowerCase();
  if (s.contains('fail') || s.contains('error') || s.contains('cannot')) {
    return const Color(0xFFE53935);
  }
  if (s.contains('load') || s.contains('showing') || s.contains('loading')) {
    return const Color(0xFFF57C00);
  }
  if (s.contains('reward') ||
      s.contains('dismiss') ||
      s.contains('loaded') ||
      s.contains('ready') ||
      s.contains('closed')) {
    return const Color(0xFF2E7D32);
  }
  return Theme.of(context).colorScheme.primary;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var adsReady = false;
  var privacyOptionsRequired = false;
  var startupStatus = 'Ready.';

  try {
    await ConsentInformation.instance.requestConsentInfoUpdate(
      const ConsentRequestParameters(),
    );

    final formError = await ConsentForm.loadAndShowConsentFormIfRequired();
    if (formError != null) {
      startupStatus = 'Consent form dismissed with error: $formError';
    }

    final privacyStatus = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    privacyOptionsRequired =
        privacyStatus == PrivacyOptionsRequirementStatus.required;
    adsReady = await ConsentInformation.instance.canRequestAds();
  } on ConsentFormException catch (e) {
    startupStatus = 'Consent update failed: ${e.error}';
    adsReady = await ConsentInformation.instance.canRequestAds();
  }

  if (adsReady) {
    await MobileAds.initialize();
    await MobileAds.setRequestConfiguration(
      const RequestConfiguration(testDeviceIds: ['TESTING_DEVICE_HASH']),
    );
    await InterstitialAdPreloader.start(
      adUnitId: AdTestIds.interstitial,
      bufferSize: 2,
    );
  } else {
    startupStatus = 'Ads cannot be requested yet.';
  }

  runApp(
    FlutterNextGenAdsDemoApp(
      adsReady: adsReady,
      privacyOptionsRequired: privacyOptionsRequired,
      startupStatus: startupStatus,
    ),
  );
}

class FlutterNextGenAdsDemoApp extends StatelessWidget {
  const FlutterNextGenAdsDemoApp({
    super.key,
    required this.adsReady,
    required this.privacyOptionsRequired,
    required this.startupStatus,
  });

  final bool adsReady;
  final bool privacyOptionsRequired;
  final String startupStatus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'admob_nextgen Demo',
      theme: buildDemoTheme(),
      home: DemoHomePage(
        adsReady: adsReady,
        privacyOptionsRequired: privacyOptionsRequired,
        startupStatus: startupStatus,
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({
    super.key,
    required this.adsReady,
    required this.privacyOptionsRequired,
    required this.startupStatus,
  });

  final bool adsReady;
  final bool privacyOptionsRequired;
  final String startupStatus;

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  AppOpenAd? _appOpenAd;
  StreamSubscription<AppState>? _appStateSubscription;
  NativeAd? _nativeBannerAd;
  NativeAd? _nativeSmallAd;
  NativeAd? _nativeLargeAd;

  bool _nativeLoading = false;
  bool _isFullScreenAdShowing = false;
  bool _isShowingAppOpenAd = false;
  String _status = 'Ready.';

  @override
  void initState() {
    super.initState();
    _status = widget.startupStatus;
    unawaited(AppStateEventNotifier.startListening());
    _appStateSubscription = AppStateEventNotifier.appStateStream.listen((
      state,
    ) {
      if (state == AppState.foreground) {
        _maybeShowAppOpenAd();
      }
    });
    if (widget.adsReady) {
      _preloadAppOpenAd();
    }
  }

  @override
  void dispose() {
    unawaited(_appStateSubscription?.cancel());
    unawaited(AppStateEventNotifier.stopListening());
    _appOpenAd?.dispose();
    _nativeBannerAd?.dispose();
    _nativeSmallAd?.dispose();
    _nativeLargeAd?.dispose();
    super.dispose();
  }

  Future<void> _preloadAppOpenAd() async {
    if (!widget.adsReady) return;
    try {
      final ad = await AppOpenAd.load(adUnitId: AdTestIds.appOpen);
      if (!mounted) {
        await ad.dispose();
        return;
      }

      _appOpenAd = ad
        ..listener = AppOpenAdListener(
          onAdShowedFullScreenContent: () {
            _isShowingAppOpenAd = true;
            _isFullScreenAdShowing = true;
          },
          onAdDismissedFullScreenContent: _finishAppOpenAd,
          onAdFailedToShowFullScreenContent: (_) => _finishAppOpenAd(),
        );
      setState(() => _status = 'App open ad pre-loaded.');
    } on AdLoadException catch (e) {
      if (mounted) setState(() => _status = 'App open load failed: ${e.error}');
    }
  }

  Future<void> _maybeShowAppOpenAd() async {
    if (_isFullScreenAdShowing || _isShowingAppOpenAd) return;
    final ad = _appOpenAd;
    if (ad == null) return;

    if (!await ad.isAvailable()) {
      _appOpenAd = null;
      _preloadAppOpenAd();
      return;
    }

    _isShowingAppOpenAd = true;
    _isFullScreenAdShowing = true;
    try {
      await ad.show();
    } catch (e) {
      _finishAppOpenAd();
      if (mounted) setState(() => _status = 'App open show failed: $e');
    }
  }

  void _finishAppOpenAd() {
    _isShowingAppOpenAd = false;
    _isFullScreenAdShowing = false;
    _appOpenAd = null;
    _preloadAppOpenAd();
  }

  void _finishFullScreenAd(String status) {
    if (!mounted) return;
    setState(() => _status = status);

    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isFullScreenAdShowing = false);
    });
  }

  void _unlockFullScreenAd(String status) {
    if (!mounted) return;
    setState(() {
      _isFullScreenAdShowing = false;
      _status = status;
    });
  }

  Future<void> _showInterstitial() async {
    if (!widget.adsReady || _isFullScreenAdShowing) return;
    setState(() {
      _isFullScreenAdShowing = true;
      _status = 'Showing interstitial...';
    });

    try {
      InterstitialAd? ad = await InterstitialAdPreloader.poll(
        adUnitId: AdTestIds.interstitial,
      );
      ad ??= await InterstitialAd.load(adUnitId: AdTestIds.interstitial);
      ad.listener = InterstitialAdListener(
        onAdDismissedFullScreenContent: () {
          _finishFullScreenAd('Interstitial dismissed.');
        },
        onAdFailedToShowFullScreenContent: (e) {
          _unlockFullScreenAd('Show failed: $e');
        },
      );
      await ad.show();
    } on AdLoadException catch (e) {
      _unlockFullScreenAd('Interstitial failed: ${e.error}');
    } catch (e) {
      _unlockFullScreenAd('Interstitial show failed: $e');
    }
  }

  Future<void> _showRewarded() async {
    if (!widget.adsReady || _isFullScreenAdShowing) return;
    var completionStatus = 'Rewarded closed before reward.';
    setState(() {
      _isFullScreenAdShowing = true;
      _status = 'Loading rewarded...';
    });

    try {
      final ad = await RewardedAd.load(adUnitId: AdTestIds.rewarded);
      ad.listener = RewardedAdListener(
        onAdDismissedFullScreenContent: () {
          _finishFullScreenAd(completionStatus);
        },
        onAdFailedToShowFullScreenContent: (e) {
          _unlockFullScreenAd('Rewarded show failed: $e');
        },
      );
      await ad.show(
        onUserEarnedReward: (reward) {
          completionStatus = 'Reward: ${reward.amount} ${reward.type}';
          if (!mounted) return;
          setState(() => _status = completionStatus);
        },
      );
    } on AdLoadException catch (e) {
      _unlockFullScreenAd('Rewarded failed: ${e.error}');
    } catch (e) {
      _unlockFullScreenAd('Rewarded show failed: $e');
    }
  }

  Future<void> _showRewardedInterstitial() async {
    if (!widget.adsReady || _isFullScreenAdShowing) return;
    var completionStatus = 'Rewarded interstitial closed before reward.';
    setState(() {
      _isFullScreenAdShowing = true;
      _status = 'Loading rewarded interstitial...';
    });

    try {
      final ad = await RewardedInterstitialAd.load(
        adUnitId: AdTestIds.rewardedInterstitial,
      );
      ad.listener = RewardedInterstitialAdListener(
        onAdDismissedFullScreenContent: () {
          _finishFullScreenAd(completionStatus);
        },
        onAdFailedToShowFullScreenContent: (e) {
          _unlockFullScreenAd('Rewarded interstitial show failed: $e');
        },
      );
      await ad.show(
        onUserEarnedReward: (reward) {
          completionStatus =
              'Rewarded interstitial: ${reward.amount} ${reward.type}';
          if (!mounted) return;
          setState(() => _status = completionStatus);
        },
      );
    } on AdLoadException catch (e) {
      _unlockFullScreenAd('Rewarded interstitial failed: ${e.error}');
    } catch (e) {
      _unlockFullScreenAd('Rewarded interstitial show failed: $e');
    }
  }

  Future<void> _loadNativeAd() async {
    if (!widget.adsReady || _nativeLoading) return;
    setState(() {
      _nativeLoading = true;
      _status = 'Loading native ad...';
    });

    final oldAds = [_nativeBannerAd, _nativeSmallAd, _nativeLargeAd];
    _nativeBannerAd = null;
    _nativeSmallAd = null;
    _nativeLargeAd = null;
    for (final ad in oldAds) {
      await ad?.dispose();
    }

    NativeAd createNativeAd(String label) {
      return NativeAd(
        adUnitId: AdTestIds.native,
        listener: NativeAdListener(
          onAdImpression: (_) {
            if (mounted) setState(() => _status = '$label impression.');
          },
          onAdClicked: (_) {
            if (mounted) setState(() => _status = '$label clicked.');
          },
        ),
      );
    }

    final bannerAd = createNativeAd('Native banner');
    final smallAd = createNativeAd('Native small');
    final largeAd = createNativeAd('Native large');
    final newAds = [bannerAd, smallAd, largeAd];

    try {
      await Future.wait(newAds.map((ad) => ad.load()));
      if (!mounted) {
        for (final ad in newAds) {
          await ad.dispose();
        }
        return;
      }

      setState(() {
        _nativeBannerAd = bannerAd;
        _nativeSmallAd = smallAd;
        _nativeLargeAd = largeAd;
        _nativeLoading = false;
        _status = 'Native layouts loaded.';
      });
    } on AdLoadException catch (e) {
      await _disposeNativeAds(newAds);
      if (mounted) {
        setState(() {
          _nativeLoading = false;
          _status = 'Native failed: ${e.error}';
        });
      }
    } catch (e) {
      await _disposeNativeAds(newAds);
      if (mounted) {
        setState(() {
          _nativeLoading = false;
          _status = 'Native error: $e';
        });
      }
    }
  }

  Future<void> _disposeNativeAds(List<NativeAd> ads) async {
    for (final ad in ads) {
      await ad.dispose();
    }
  }

  Future<void> _showPrivacyOptions() async {
    final error = await ConsentForm.showPrivacyOptionsForm();
    if (!mounted) return;
    setState(() {
      _status = error == null
          ? 'Privacy options closed.'
          : 'Privacy options error: $error';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar(adsReady: widget.adsReady),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatusCard(status: _status),
                    const SizedBox(height: 24),
                    if (widget.privacyOptionsRequired) ...[
                      PrivacySection(onShowPrivacyOptions: _showPrivacyOptions),
                      const SizedBox(height: 24),
                    ],
                    FullScreenAdsSection(
                      adsReady: widget.adsReady,
                      isShowingAd: _isFullScreenAdShowing,
                      onShowInterstitial: _showInterstitial,
                      onShowRewarded: _showRewarded,
                      onShowRewardedInterstitial: _showRewardedInterstitial,
                      onShowAppOpen: _maybeShowAppOpenAd,
                    ),
                    const SizedBox(height: 24),
                    NativeAdsSection(
                      adsReady: widget.adsReady,
                      isLoading: _nativeLoading,
                      onLoadNativeAds: _loadNativeAd,
                      bannerAd: _nativeBannerAd,
                      smallAd: _nativeSmallAd,
                      largeAd: _nativeLargeAd,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.adsReady) const BottomBannerAd(),
          ],
        ),
      ),
    );
  }
}
