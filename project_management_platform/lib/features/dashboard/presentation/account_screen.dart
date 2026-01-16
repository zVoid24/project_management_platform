import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkNavy,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = (state is AuthAuthenticated) ? state.user : null;
          final email = user?.email ?? 'user@example.com';
          final name = user?.fullName ?? email.split('@')[0];

          String initials = 'US';
          if (name.isNotEmpty) {
            final names = name.trim().split(' ');
            if (names.length >= 2) {
              initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
            } else if (names.isNotEmpty) {
              initials = names[0]
                  .substring(0, names[0].length >= 2 ? 2 : 1)
                  .toUpperCase();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (user?.role == 'developer')
                  _AccountOption(
                    icon: Icons.check_circle_outline,
                    label: 'View Tasks',
                    onTap: () {
                      // Navigate to home (Dashboard)
                      // Since we pushed this screen, popping returns to dashboard.
                      // But user said "view task should take developer to homepage"
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                _AccountOption(
                  icon: Icons.logout,
                  label: 'Log Out',
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    // AuthListener in Dashboard will handle navigation to login
                  },
                  color: AppTheme.errorRed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _AccountOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.darkNavy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color.withOpacity(0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
