import 'dart:async';

import 'package:flutter/services.dart';

/// The app foreground/background state.
enum AppState {
  /// The app process is in the background.
  background,

  /// The app process is in the foreground.
  foreground,
}

/// Notifies changes in the Android app process foreground/background state.
///
/// This is preferred over `WidgetsBindingObserver` for app open ads because
/// showing a full-screen ad can change the Flutter activity lifecycle without
/// the user actually leaving the app.
class AppStateEventNotifier {
  static const MethodChannel _methodChannel = MethodChannel(
    'admob_nextgen/app_state_method',
  );
  static const EventChannel _eventChannel = EventChannel(
    'admob_nextgen/app_state_event',
  );

  /// Subscribe after calling [startListening].
  static Stream<AppState> get appStateStream =>
      _eventChannel.receiveBroadcastStream().map(
        (event) =>
            event == 'foreground' ? AppState.foreground : AppState.background,
      );

  /// Starts observing Android process lifecycle changes.
  static Future<void> startListening() =>
      _methodChannel.invokeMethod<void>('start');

  /// Stops observing Android process lifecycle changes.
  static Future<void> stopListening() =>
      _methodChannel.invokeMethod<void>('stop');
}
