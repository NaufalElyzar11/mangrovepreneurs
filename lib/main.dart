import 'package:flutter/material.dart';
import 'core/theme/mangrove_theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/statistics_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MangroveApp());
}

/// Main application widget
/// Entry point for the Kalulut Hive Monitor app
class MangroveApp extends StatelessWidget {
  const MangroveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mangrovepreneurs',
      debugShowCheckedModeBanner: false,
      theme: MangroveTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

/// Main screen with stateful BottomNavigationBar
/// Uses IndexedStack for persistent navigation state
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Pages - using list to maintain state across tab switches
  final List<Widget> _pages = const [
    DashboardPage(),
    StatisticsPage(),
    SettingsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state of all pages
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: MangroveTheme.primaryGreenDark.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
