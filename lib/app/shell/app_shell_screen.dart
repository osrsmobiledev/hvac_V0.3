import 'package:flutter/material.dart';
import '../../features/certificate_draft/ui/verbrandingsattest_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_drawer.dart';
import 'app_shell_controller.dart';
import 'applet_content_placeholder.dart';

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
            final isCombustion =
                _controller.activeApplet == AppletType.combustion;

            final Widget currentBody = switch (_controller.activeApplet) {
              AppletType.home => DashboardScreen(controller: _controller),
              AppletType.combustion =>
                VerbrandingsattestScreen(controller: _controller),
              _ => AppletContentPlaceholder(
                  appBarTitle: _controller.appBarTitle,
                  onBackToHome: () => _controller.selectApplet(AppletType.home),
                ),
            };

            return Scaffold(
              // Persistent AppBar: stays visible at all times
              appBar: AppBar(
                toolbarHeight:
                    (isCombustion && !isWideScreen) ? 74.0 : kToolbarHeight,
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
                title: _buildAppBarTitle(isWideScreen),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.goldHairline,
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
                          color: AppColors.goldHairline,
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

  /// Builds the persistent AppBar title adapting between a clean 2-line title
  /// on narrow phone viewports and 1-line title on wider tablet displays.
  Widget _buildAppBarTitle(bool isWideScreen) {
    if (_controller.activeApplet == AppletType.combustion) {
      if (!isWideScreen) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verbrandingsattest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Vlaanderen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      } else {
        return const Text(
          'Verbrandingsattest Vlaanderen',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        );
      }
    }
    return Text(
      _controller.appBarTitle,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    );
  }
}
