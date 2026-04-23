import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../dashboard/category_dashboard_screen.dart';
import '../user/user_home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isBootstrapping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.appUser == null) {
      return const LoginScreen();
    } else {
      return authProvider.isAdmin
          ? const CategoryDashboard()
          : const UserHome();
    }
  }
}
