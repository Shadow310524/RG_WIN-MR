import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgwin_crm/core/routing/app_router.dart';
import 'package:rgwin_crm/core/theme/app_theme.dart';
import 'package:rgwin_crm/features/auth/presentation/auth_controller.dart';

class RgWinApp extends ConsumerStatefulWidget {
  const RgWinApp({super.key});

  @override
  ConsumerState<RgWinApp> createState() => _RgWinAppState();
}

class _RgWinAppState extends ConsumerState<RgWinApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "RG WIN - Healix CRM",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
