import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

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
