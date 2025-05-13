import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1C1C1E), 
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Flow", style: TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text('Главная', style: TextStyle(color: Colors.white)),
            onTap: () => context..go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Настройки', style: TextStyle(color: Colors.white)),
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}
