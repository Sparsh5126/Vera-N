import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/storage_providers.dart';
import 'core/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageServices.open();
  runApp(
    ProviderScope(
      overrides: [storageProvider.overrideWithValue(storage)],
      child: const App(),
    ),
  );
  // Pick up notes added or changed outside the app, without delaying start.
  unawaited(storage.reconcile());
}
