import 'package:flutter/material.dart';

import '../features/assistant/presentation/assistant_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import 'home_shell.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const categories = '/categories';
  static const budgets = '/budgets';
  static const about = '/about';
  static const assistant = '/assistant';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.categories => const CategoriesScreen(),
      AppRoutes.budgets => const BudgetsScreen(),
      AppRoutes.about => const AboutScreen(),
      AppRoutes.assistant => const AssistantScreen(),
      _ => const HomeShell(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
