import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Root bootstrap wrapping application with Riverpod state management
  runApp(const ProviderScope(child: RgWinApp()));
}
