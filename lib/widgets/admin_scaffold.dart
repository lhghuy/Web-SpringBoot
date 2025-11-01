// lib/widgets/admin_scaffold.dart
import 'package:flutter/material.dart';

/// AdminScaffold
/// Sử dụng để bọc các màn hình quản trị.
/// Example:
///   AdminScaffold(
///     title: 'Quản lý sản phẩm',
///     child: YourContentWidget(),
///   );
class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AdminScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, title),
      drawer: _AdminDrawer(currentRoute: ModalRoute.of(context)?.settings.name),
      body: SafeArea(child: child),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      title: const Text('Hệ thống Quản lý Thực phẩm HKD'),
      backgroundColor: const Color(0xFF667EEA),
      elevation: 0,
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: show profile / settings
                },
                icon: const Icon(Icons.person),
              ),
            ],
          ),
        )
      ],
    );
  }
}

/// Drawer giống sidebar admin HTML (responsive cho mobile)
class _AdminDrawer extends StatelessWidget {
  final String? currentRoute;
  const _AdminDrawer({this.currentRoute});

  @override
  Widget build(BuildContext context) {
    Widget navItem(String label, IconData icon, String route) {
      final bool active = currentRoute != null && currentRoute!.startsWith(route);
      return ListTile(
        leading: Icon(icon, color: active ? const Color(0xFF667EEA) : Colors.grey[700]),
        title: Text(label, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        tileColor: active ? Colors.grey.withOpacity(0.08) : null,
        onTap: () {
          Navigator.pop(context); // đóng drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Color(0xFF667EEA))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Hệ thống Quản lý', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            navItem('Quản lý sản phẩm', Icons.fastfood, '/admin/foods'),
            navItem('Quản lý nhân viên', Icons.people, '/admin/staff'),
            navItem('Thống kê doanh thu', Icons.bar_chart, '/admin/revenue'),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                // TODO: gọi API logout hoặc xóa token
                Navigator.popUntil(context, (route) => route.isFirst);
                // hoặc Navigator.pushReplacementNamed(context, '/login') tuỳ flow
              },
            ),
          ],
        ),
      ),
    );
  }
}
