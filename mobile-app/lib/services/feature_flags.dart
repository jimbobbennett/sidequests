import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart';

enum Flags { useAppwrite }

extension FlagsExtension on Flags {
  String get key {
    switch (this) {
      case Flags.useAppwrite:
        return "use-app-write";
    }
  }
}

class FeatureFlags extends ChangeNotifier {
  FeatureFlags._(this._client) {
    _sub = _client.flagChanges.listen((changeEvent) {
      notifyListeners();
    });
  }

  final LDClient _client;
  late StreamSubscription _sub;

  bool isEnabled(Flags flag) {
    final result = _client.boolVariation(flag.key, false);
    return result;
  }

  static Future<FeatureFlags> create() async {
    String launchDarklyMobileKey = dotenv.env["LAUNCHDARKLY_MOBILE_KEY"]!;
    final config = LDConfig(launchDarklyMobileKey, AutoEnvAttributes.enabled);

    final context = LDContextBuilder().kind("user", "none").build();
    final client = LDClient(config, context);

    await client.start().timeout(const Duration(seconds: 5), onTimeout: () => false);

    return FeatureFlags._(client);
  }
}
