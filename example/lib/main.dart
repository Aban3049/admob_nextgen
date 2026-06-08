import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/material.dart';

import 'ad_demo_constants.dart';
import 'ad_demo_theme.dart';
import 'widgets/ad_demo_widgets.dart';

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

class _DemoHomePageState extends State<DemoHomePage>
    with WidgetsBindingObserver {
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeBannerAd;
  NativeAd? _nativeSmallAd;
  NativeAd? _nativeLargeAd;

  bool _nativeLoading = false;
  bool _wasInBackground = false;
  bool _isFullScreenAdShowing = false;
  bool _isShowingAppOpenAd = false;
  String _status = 'Ready.';

  @override
  void initState() {
    super.initState();
    _status = widget.startupStatus;
    WidgetsBinding.instance.addObserver(this);
    if (widget.adsReady) {
      _preloadAppOpenAd();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    _nativeBannerAd?.dispose();
    _nativeSmallAd?.dispose();
    _nativeLargeAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppReturnedToForeground();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (!_isFullScreenAdShowing) {
          _wasInBackground = true;
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
    }
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

  void _onAppReturnedToForeground() {
    if (!_wasInBackground) return;
    _wasInBackground = false;
    _maybeShowAppOpenAd();
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
