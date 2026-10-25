import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/certificate_draft/ui/verbrandingsattest_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../localization/app_dictionary.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyOrientationPolicy();
  }

  void _applyOrientationPolicy() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Tablet & landscape threshold (720px) — strictly active on true tablets (>= 600dp shortest side)
            final isWideScreen = isTablet && constraints.maxWidth >= 720;
            final isHome = _controller.activeApplet == AppletType.home;

            final Widget currentBody = switch (_controller.activeApplet) {
              AppletType.home => DashboardScreen(controller: _controller),
              AppletType.combustion =>
                VerbrandingsattestScreen(controller: _controller),
              _ => AppletContentPlaceholder(
                  appBarTitle: _controller.appBarTitle,
                  onBackToHome: () => _controller.selectApplet(AppletType.home),
                ),
            };

            return PopScope(
              canPop: isHome && !_isDrawerOpen,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                if (_isDrawerOpen) {
                  _phoneScaffoldKey.currentState?.closeDrawer();
                  return;
                }
                if (!isHome) {
                  _controller.selectApplet(AppletType.home);
                }
              },
              child: Scaffold(
                // Persistent AppBar: stays visible at all times
                appBar: AppBar(
                  toolbarHeight: kToolbarHeight,
                  centerTitle: true,
                  leading: isWideScreen
                      ? null
                      : IconButton(
                          key: const ValueKey('menu_button'),
                          icon: const Icon(Icons.menu_rounded),
                          tooltip: _isDrawerOpen
                              ? AppDictionary.tooltipCloseMenu
                              : AppDictionary.tooltipOpenMenu,
                          onPressed: () {
                            final scaffoldState =
                                _phoneScaffoldKey.currentState;
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
                            if (_phoneScaffoldKey.currentState?.isDrawerOpen ==
                                true) {
                              _phoneScaffoldKey.currentState?.closeDrawer();
                            }
                          },
                        ),
                        body: currentBody,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the persistent AppBar title displaying a clean 1-line title
  /// auto-scaled with [FittedBox] so it never wraps or cuts off on any screen.
  Widget _buildAppBarTitle(bool isWideScreen) {
    if (_controller.activeApplet == AppletType.combustion) {
      return const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppDictionary.menuCombustion,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            letterSpacing: 0.2,
          ),
        ),
      );
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
