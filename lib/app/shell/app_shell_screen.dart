import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_drawer.dart';
import 'app_shell_controller.dart';

/// Main Adaptive App Shell for HVAC Field Service.
///
/// Features:
/// - Persistent top AppBar across all screens and applets.
/// - Dynamic AppBar title reflecting the active applet.
/// - Adaptive navigation:
///   * On phones (< 720px): Hamburger icon opens the Drawer directly underneath the persistent AppBar.
///   * On tablets (>= 720px): Side menu is permanently docked on the left.
class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  final AppShellController _controller = AppShellController();
  final GlobalKey<ScaffoldState> _phoneScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Tablet & landscape threshold (720px)
            final isWideScreen = constraints.maxWidth >= 720;

            return Scaffold(
              // Persistent AppBar: stays visible at all times
              appBar: AppBar(
                leading: isWideScreen
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.menu),
                        tooltip: 'Menu openen',
                        onPressed: () {
                          // Opens the phone drawer directly underneath this persistent AppBar
                          _phoneScaffoldKey.currentState?.openDrawer();
                        },
                      ),
                title: Text(_controller.appBarTitle),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.hairlineBorder,
                  ),
                ),
              ),
              body: isWideScreen
                  // Tablet/wide screen layout: permanent side menu on left, body on right
                  ? Row(
                      children: [
                        AppDrawer(
                          controller: _controller,
                          isPermanent: true,
                        ),
                        const VerticalDivider(
                          width: 1.0,
                          thickness: 1.0,
                          color: AppColors.hairlineBorder,
                        ),
                        Expanded(
                          child: _ShellBodyPlaceholder(
                            activeApplet: _controller.activeApplet,
                            appBarTitle: _controller.appBarTitle,
                          ),
                        ),
                      ],
                    )
                  // Phone layout: inner Scaffold whose drawer opens underneath the persistent AppBar
                  : Scaffold(
                      key: _phoneScaffoldKey,
                      drawer: AppDrawer(
                        controller: _controller,
                        isPermanent: false,
                        onItemTapped: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      body: _ShellBodyPlaceholder(
                        activeApplet: _controller.activeApplet,
                        appBarTitle: _controller.appBarTitle,
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

/// Temporary clean placeholder for Slice 1.2.
/// The 4 Bento Squircle Applet Tiles will be implemented here in Slice 1.3.
class _ShellBodyPlaceholder extends StatelessWidget {
  final AppletType activeApplet;
  final String appBarTitle;

  const _ShellBodyPlaceholder({
    required this.activeApplet,
    required this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.carbonCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hairlineBorder),
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appBarTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dashboard applet launcher tegels worden gebouwd in Slice 1.3.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
