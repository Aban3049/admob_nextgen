import 'dart:async';

import 'package:admob_nextgen/admob_nextgen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _methodChannel = MethodChannel('admob_nextgen/app_state_method');
const _eventChannel = MethodChannel('admob_nextgen/app_state_event');
const _codec = StandardMethodCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_methodChannel, null);
    messenger.setMockMethodCallHandler(_eventChannel, null);
  });

  test(
    'startListening and stopListening invoke native notifier methods',
    () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_methodChannel, (call) async {
            calls.add(call.method);
            return null;
          });

      await AppStateEventNotifier.startListening();
      await AppStateEventNotifier.stopListening();

      expect(calls, ['start', 'stop']);
    },
  );

  test('appStateStream maps foreground and background events', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_eventChannel, (_) async => null);

    final states = <AppState>[];
    final subscription = AppStateEventNotifier.appStateStream.listen(
      states.add,
    );
    await Future<void>.delayed(Duration.zero);

    await _dispatchEvent('foreground');
    await _dispatchEvent('background');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [AppState.foreground, AppState.background]);
  });
}

Future<void> _dispatchEvent(String event) async {
  final completer = Completer<void>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'admob_nextgen/app_state_event',
        _codec.encodeSuccessEnvelope(event),
        (_) => completer.complete(),
      );
  await completer.future;
}
