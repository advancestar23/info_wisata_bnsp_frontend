import 'package:flutter/material.dart';
import './drawer.dart';
import '../widgets/connectivity_status.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showDrawer;
  
  const MainLayout({
    super.key, 
    required this.title, 
    required this.child,
    this.actions,
    this.leading,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        actions: actions,
        leading: leading,
      ),
      drawer: showDrawer ? const DrawerMenu() : null,
      body: Column(
        children: [
          const ConnectivityStatus(),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

