import 'package:flutter/services.dart';

import '../core/channel.dart';

/// Error returned by the User Messaging Platform consent APIs.
class ConsentFormError {
  const ConsentFormError({required this.errorCode, required this.message});

  /// UMP platform error code.
  final int errorCode;

  /// Human-readable error message.
  final String message;

  factory ConsentFormError.fromMap(Map<dynamic, dynamic> map) =>
      ConsentFormError(
        errorCode: (map['errorCode'] as int?) ?? 0,
        message: (map['message'] as String?) ?? 'unknown',
      );

  factory ConsentFormError.fromPlatformException(PlatformException error) =>
      ConsentFormError(
        errorCode: int.tryParse(error.code) ?? 0,
        message: error.message ?? 'unknown',
      );

  @override
  String toString() =>
      'ConsentFormError(errorCode: $errorCode, message: $message)';
}

/// Exception thrown by consent APIs that cannot complete successfully.
class ConsentFormException implements Exception {
  const ConsentFormException(this.error);

  final ConsentFormError error;

  @override
  String toString() => 'ConsentFormException: $error';
}

/// User consent status values reported by UMP.
enum ConsentStatus { unknown, required, notRequired, obtained }

/// Indicates whether a privacy options entry point must be shown.
enum PrivacyOptionsRequirementStatus { unknown, required, notRequired }

/// Debug geography values for testing consent forms.
enum DebugGeography { disabled, eea, notEea, regulatedUsState, other }

/// Debug-only UMP settings.
class ConsentDebugSettings {
  const ConsentDebugSettings({
    this.debugGeography,
    this.testIdentifiers = const <String>[],
  });

  final DebugGeography? debugGeography;
  final List<String> testIdentifiers;

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (debugGeography != null)
      'debugGeography': _debugGeographyToPlatform(debugGeography!),
    if (testIdentifiers.isNotEmpty) 'testIdentifiers': testIdentifiers,
  };

  /// UMP Android debug geography integer constants.
  static int _debugGeographyToPlatform(DebugGeography value) {
    switch (value) {
      case DebugGeography.disabled:
        return 0;
      case DebugGeography.eea:
        return 1;
      case DebugGeography.notEea:
        return 2;
      case DebugGeography.regulatedUsState:
        return 3;
      case DebugGeography.other:
        return 4;
    }
  }
}

/// Parameters used when requesting updated consent information.
class ConsentRequestParameters {
  const ConsentRequestParameters({
    this.tagForUnderAgeOfConsent,
    this.consentDebugSettings,
  });

  final bool? tagForUnderAgeOfConsent;
  final ConsentDebugSettings? consentDebugSettings;

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (tagForUnderAgeOfConsent != null)
      'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
    if (consentDebugSettings != null)
      'consentDebugSettings': consentDebugSettings!.toMap(),
  };
}

/// Utility methods for reading and updating UMP consent information.
class ConsentInformation {
  ConsentInformation._();

  static final ConsentInformation instance = ConsentInformation._();

  /// Request updated consent information. Call this on every app launch.
  Future<void> requestConsentInfoUpdate(
    ConsentRequestParameters parameters,
  ) async {
    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>('requestConsentInfoUpdate', {
          'params': parameters.toMap(),
        });
    if (raw != null) {
      throw ConsentFormException(ConsentFormError.fromMap(raw));
    }
  }

  /// Returns true if the app can request ads with the current consent state.
  Future<bool> canRequestAds() async {
    final raw = await AdsChannel.instance.channel.invokeMethod<bool>(
      'canRequestAds',
    );
    return raw ?? false;
  }

  /// Returns true if a consent form is currently available.
  Future<bool> isConsentFormAvailable() async {
    final raw = await AdsChannel.instance.channel.invokeMethod<bool>(
      'isConsentFormAvailable',
    );
    return raw ?? false;
  }

  /// Returns the cached consent status.
  Future<ConsentStatus> getConsentStatus() async {
    final raw = await AdsChannel.instance.channel.invokeMethod<String>(
      'getConsentStatus',
    );
    return _consentStatusFromString(raw);
  }

  /// Returns whether a privacy options entry point is required.
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async {
    final raw = await AdsChannel.instance.channel.invokeMethod<String>(
      'getPrivacyOptionsRequirementStatus',
    );
    return _privacyStatusFromString(raw);
  }

  /// Reset UMP state. Use only for debugging and testing.
  Future<void> reset() =>
      AdsChannel.instance.channel.invokeMethod<void>('resetConsentInformation');

  static ConsentStatus _consentStatusFromString(String? value) {
    switch (value) {
      case 'required':
        return ConsentStatus.required;
      case 'notRequired':
        return ConsentStatus.notRequired;
      case 'obtained':
        return ConsentStatus.obtained;
      default:
        return ConsentStatus.unknown;
    }
  }

  static PrivacyOptionsRequirementStatus _privacyStatusFromString(
    String? value,
  ) {
    switch (value) {
      case 'required':
        return PrivacyOptionsRequirementStatus.required;
      case 'notRequired':
        return PrivacyOptionsRequirementStatus.notRequired;
      default:
        return PrivacyOptionsRequirementStatus.unknown;
    }
  }
}

/// Methods for loading and showing UMP consent forms.
class ConsentForm {
  ConsentForm._();

  /// Loads and shows a consent form if one is required.
  ///
  /// Returns a [ConsentFormError] when the form was dismissed with an error,
  /// otherwise returns null.
  static Future<ConsentFormError?> loadAndShowConsentFormIfRequired() async {
    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>(
          'loadAndShowConsentFormIfRequired',
        );
    return raw == null ? null : ConsentFormError.fromMap(raw);
  }

  /// Shows the privacy options form.
  ///
  /// Call this from a user-visible privacy options button when
  /// [PrivacyOptionsRequirementStatus.required] is reported.
  static Future<ConsentFormError?> showPrivacyOptionsForm() async {
    final raw = await AdsChannel.instance.channel
        .invokeMethod<Map<dynamic, dynamic>>('showPrivacyOptionsForm');
    return raw == null ? null : ConsentFormError.fromMap(raw);
  }
}
