import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_views/overview_tab.dart';
import 'admin_views/users_tab.dart';
import 'admin_views/transfers_tab.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.swap_horiz_outlined), text: 'Transfers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [OverviewTab(), UsersTab(), TransfersTab()],
        ),
      ),
    );
  }
}
