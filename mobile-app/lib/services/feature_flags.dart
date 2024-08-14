import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart';

/// The flags this app supports
enum Flags {
  useAppwrite, // Should the back end database be app write? If not, SQLite will be used
}

extension FlagsExtension on Flags {
  /// Getter for the key associated with each flag.
  ///
  /// This getter returns a String representation of the flag's key,
  /// which is typically used for configuration or storage purposes.
  String get key {
    switch (this) {
      case Flags.useAppwrite:
        // Returns the key for the useAppwrite flag
        return "use-app-write";
    }
  }
}

/// A class that manages feature flags using LaunchDarkly.
///
/// This class extends [ChangeNotifier] to allow listeners to be notified
/// when feature flag values change. It uses an [LDClient] to interact with
/// LaunchDarkly's SDK.
///
/// The class provides methods to check if a feature flag is enabled and
/// a factory method to create and initialize a new instance.
class FeatureFlags extends ChangeNotifier {
  FeatureFlags._(this._client) {
    _sub = _client.flagChanges.listen((changeEvent) {
      notifyListeners();
    });
  }

  final LDClient _client;
  late StreamSubscription _sub;

  /// Checks if a specific feature flag is enabled.
  ///
  /// This function queries the feature flag service to determine
  /// if a given flag is enabled or disabled.
  ///
  /// Parameters:
  /// - [flag]: An enum of type [Flags] representing the feature flag to check.
  ///
  /// Returns:
  /// - [bool]: True if the flag is enabled, false otherwise.
  ///
  /// If the feature flag service fails or the flag is not found,
  /// this function will return false as a default value.
  bool isEnabled(Flags flag) {
    // Query the feature flag service for the boolean value of the flag
    final result = _client.boolVariation(flag.key, false);

    // Return the result of the feature flag query
    return result;
  }

  /// Creates and initializes a FeatureFlags instance.
  ///
  /// This static method sets up LaunchDarkly client with the provided configuration
  /// and returns a new FeatureFlags object.
  ///
  /// Returns a Future that completes with a FeatureFlags instance.
  static Future<FeatureFlags> create() async {
    // Retrieve the LaunchDarkly mobile key from environment variables
    String launchDarklyMobileKey = dotenv.env["LAUNCHDARKLY_MOBILE_KEY"]!;

    // Configure LaunchDarkly client with the mobile key and enable auto environment attributes
    final config = LDConfig(launchDarklyMobileKey, AutoEnvAttributes.enabled);

    // Create a LaunchDarkly context for a generic user
    final context = LDContextBuilder().kind("user", "none").build();

    // Initialize the LaunchDarkly client with the config and context
    final client = LDClient(config, context);

    // Start the LaunchDarkly client with a 5-second timeout
    // If the client fails to start within the timeout, it returns false
    await client.start().timeout(const Duration(seconds: 5), onTimeout: () => false);

    // Return a new FeatureFlags instance with the initialized client
    return FeatureFlags._(client);
  }
}
