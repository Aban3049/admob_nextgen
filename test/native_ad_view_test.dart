import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native template view types are stable', () {
    expect(NativeAdTemplate.banner.viewType, 'next_gen_sdk/native_banner');
    expect(NativeAdTemplate.small.viewType, 'next_gen_sdk/native_small');
    expect(NativeAdTemplate.large.viewType, 'next_gen_sdk/native_large');
    expect(NativeAdTemplate.large.defaultHeight, 380);
  });

  test('native style encodes optional Android creation params', () {
    final style = NativeAdViewStyle(
      cardColor: Colors.white,
      callToActionColor: Colors.green,
      callToActionTextColor: Colors.black,
      callToActionText: 'Install now',
      callToActionHeight: 48,
      callToActionCornerRadius: 14,
      titleColor: Colors.blue,
      descriptionColor: Colors.grey,
      adBadgeText: 'Sponsored',
      adBadgeTextColor: Colors.white,
      adBadgeColor: Colors.orange,
      adBadgeBorderColor: Colors.deepOrange,
      adBadgeBorderWidth: 2,
      adBadgeCornerRadius: 6,
    );

    expect(style.toMap(), {
      'cardColor': Colors.white.toARGB32(),
      'callToActionColor': Colors.green.toARGB32(),
      'callToActionTextColor': Colors.black.toARGB32(),
      'callToActionText': 'Install now',
      'callToActionHeight': 48,
      'callToActionCornerRadius': 14,
      'titleColor': Colors.blue.toARGB32(),
      'descriptionColor': Colors.grey.toARGB32(),
      'adBadgeText': 'Sponsored',
      'adBadgeTextColor': Colors.white.toARGB32(),
      'adBadgeColor': Colors.orange.toARGB32(),
      'adBadgeBorderColor': Colors.deepOrange.toARGB32(),
      'adBadgeBorderWidth': 2,
      'adBadgeCornerRadius': 6,
    });
  });

  testWidgets('native template widgets show placeholder before load', (
    tester,
  ) async {
    final ad = NativeAd(adUnitId: 'unit');

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            NativeBannerAdView(
              nativeAd: ad,
              placeholder: const Text('banner placeholder'),
            ),
            NativeSmallAdView(
              nativeAd: ad,
              placeholder: const Text('small placeholder'),
            ),
            NativeLargeAdView(
              nativeAd: ad,
              placeholder: const Text('large placeholder'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('banner placeholder'), findsOneWidget);
    expect(find.text('small placeholder'), findsOneWidget);
    expect(find.text('large placeholder'), findsOneWidget);
  });
}
