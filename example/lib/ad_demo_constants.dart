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
