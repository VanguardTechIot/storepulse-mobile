import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../auth/data/token_manager.dart';
import '../../dashboard_analytics/presentation/dashboard_page.dart';
import '../../monitoring/presentation/monitoring_page.dart';
import '../../subscriptions_payments/presentation/subscription_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _currentRole = 'GALLERY_ADMINISTRATOR';
  final TokenManager _tokenManager = getIt<TokenManager>();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final savedRole = await _tokenManager.getRole();
    if (mounted) {
      setState(() => _currentRole = savedRole);
    }
  }

  Future<void> _switchRole(String newRole) async {
    await _tokenManager.setRole(newRole);
    if (mounted) {
      setState(() => _currentRole = newRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentRole == 'GALLERY_ADMINISTRATOR';

    final pages = [
      DashboardPage(
        key: ValueKey('dashboard_$_currentRole'),
        currentRole: _currentRole,
      ),
      MonitoringPage(key: ValueKey('monitoring_$_currentRole')),
      SubscriptionPage(
        key: ValueKey('subscriptions_$_currentRole'),
        currentRole: _currentRole,
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
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Cambiar vista de segmento objetivo',
            icon: const Icon(Icons.switch_account, color: Color(0xFF38BDF8)),
            onSelected: _switchRole,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'GALLERY_ADMINISTRATOR',
                child: Row(
                  children: [
                    Icon(Icons.domain, size: 18, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Segmento 1: Admin. de Galería'),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'TENANT',
                child: Row(
                  children: [
                    Icon(Icons.storefront, size: 18, color: Color(0xFF0EA5E9)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Segmento 2: Inquilino de Local'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _tokenManager.clearAll();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
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
            selectedIcon: const Icon(
              Icons.analytics,
              color: Color(0xFF0EA5E9),
            ),
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