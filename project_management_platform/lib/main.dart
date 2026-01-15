import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/admin_dashboard.dart';
import 'features/dashboard/presentation/buyer_dashboard.dart';
import 'features/dashboard/presentation/developer_dashboard.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/buyer',
      builder: (context, state) => const BuyerDashboard(),
    ),
    GoRoute(
      path: '/developer',
      builder: (context, state) => const DeveloperDashboard(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => sl<AuthBloc>())],
      child: MaterialApp.router(
        title: 'Project Management Platform',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routerConfig: _router,
      ),
    );
  }
}
