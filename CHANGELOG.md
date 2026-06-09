## 0.1.0-beta.4

- Fixed Native Validator errors for banner and small native ad templates by
  registering them without hidden undersized media views.
- Fixed false Native Validator media-size errors for large native ads by
  registering the media view after Android completes its first layout pass.
- Prevented delayed large native ad registration after the platform view has
  been disposed.

## 0.1.0-beta.3

- Fixed Linux/pub.dev analysis failures caused by case-sensitive Dart source paths.
- Renamed interstitial and rewarded interstitial source directories to lowercase Dart file convention paths.
- Updated package exports and imports for the normalized paths.
- Improved pub.dev README preview with banner and native ad screenshots.
- Consolidated the example app into `example/lib/main.dart` so pub.dev shows the full example code.
- Excluded generated dartdoc output from publish archives.

## 0.1.0-beta.2

- Updated README.
- Added screenshots for pub.dev package page.

## 0.1.0-beta.1

Initial beta release.

- Android Google Mobile Ads Next-Gen SDK initialization.
- UMP consent helpers.
- Banner, interstitial, rewarded, rewarded interstitial, and app open ads.
- Interstitial and rewarded interstitial preloaders.
- Standard native ads with three prebuilt templates: banner, small, and large.
- Optional native template styling for card color, CTA button, title, description, and ad badge.
