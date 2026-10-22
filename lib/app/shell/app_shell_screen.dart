import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
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
  bool _isDrawerOpen = false;

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

            final Widget currentBody =
                _controller.activeApplet == AppletType.home
                    ? DashboardScreen(controller: _controller)
                    : _AppletContentPlaceholder(
                        activeApplet: _controller.activeApplet,
                        appBarTitle: _controller.appBarTitle,
                        onBackToHome: () =>
                            _controller.selectApplet(AppletType.home),
                      );

            return Scaffold(
              // Persistent AppBar: stays visible at all times
              appBar: AppBar(
                centerTitle: true,
                leading: isWideScreen
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.menu),
                        tooltip: _isDrawerOpen ? 'Menu sluiten' : 'Menu openen',
                        onPressed: () {
                          final scaffoldState = _phoneScaffoldKey.currentState;
                          if (scaffoldState == null) return;
                          if (scaffoldState.isDrawerOpen) {
                            scaffoldState.closeDrawer();
                          } else {
                            scaffoldState.openDrawer();
                          }
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
                        Expanded(child: currentBody),
                      ],
                    )
                  // Phone layout: inner Scaffold whose drawer opens underneath the persistent AppBar
                  : Scaffold(
                      key: _phoneScaffoldKey,
                      onDrawerChanged: (isOpen) {
                        if (_isDrawerOpen != isOpen) {
                          setState(() {
                            _isDrawerOpen = isOpen;
                          });
                        }
                      },
                      drawer: AppDrawer(
                        controller: _controller,
                        isPermanent: false,
                        onItemTapped: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      body: currentBody,
                    ),
            );
          },
        );
      },
    );
  }
}

/// Placeholder displayed when an applet is selected from the dashboard or drawer.
/// Will be replaced by the 7-tab workflow in Milestone 2.
class _AppletContentPlaceholder extends StatelessWidget {
  final AppletType activeApplet;
  final String appBarTitle;
  final VoidCallback onBackToHome;

  const _AppletContentPlaceholder({
    required this.activeApplet,
    required this.appBarTitle,
    required this.onBackToHome,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.carbonCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hairlineBorder),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 26,
                  color: AppColors.amberGold,
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
                'De 7-tab workflow voor dit attest wordt gebouwd in Milestone 2.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onBackToHome,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Terug naar dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
