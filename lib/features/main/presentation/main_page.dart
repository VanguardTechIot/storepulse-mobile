import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_routes.dart';
import '../../dashboard_analytics/presentation/dashboard_page.dart';
import '../../iam/domain/role.dart';
import '../../iam/presentation/session_state.dart';
import '../../iam/presentation/session_view_model.dart';
import '../../monitoring/presentation/monitoring_page.dart';
import '../../subscriptions_payments/presentation/subscription_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  Future<void> _confirmSignOut(BuildContext context) async {
    final sessionViewModel = context.read<SessionViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión en StorePulse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await sessionViewModel.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select<SessionViewModel, Role>(
      (viewModel) => switch (viewModel.state) {
        SessionAuthenticated(:final user) => user.role,
        _ => Role.tenant,
      },
    );
    final isAdmin = role == Role.galleryAdministrator;
    final currentRole = role.value;

    final pages = [
      DashboardPage(
        key: ValueKey('dashboard_$currentRole'),
        currentRole: currentRole,
      ),
      MonitoringPage(key: ValueKey('monitoring_$currentRole')),
      SubscriptionPage(
        key: ValueKey('subscriptions_$currentRole'),
        currentRole: currentRole,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StorePulse IoT',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              isAdmin
                  ? 'Segmento 1: Administrador de Galería'
                  : 'Segmento 2: Inquilino de Local Comercial',
              style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE0F2FE),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics, color: Color(0xFF0EA5E9)),
            label: isAdmin ? 'Dashboard Galería' : 'Dashboard Local',
          ),
          const NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors, color: Color(0xFF0EA5E9)),
            label: 'Monitoreo',
          ),
          NavigationDestination(
            icon: const Icon(Icons.workspace_premium_outlined),
            selectedIcon: const Icon(
              Icons.workspace_premium,
              color: Color(0xFF0EA5E9),
            ),
            label: isAdmin ? 'Suscripción y Pagos' : 'Cobertura IoT',
          ),
        ],
      ),
    );
  }
}
