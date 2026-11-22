import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/certificate_draft/ui/verbrandingsattest_screen.dart';
import '../../features/email_delivery/data/email_delivery_coordinator.dart';
import '../../features/technician_settings/technician_settings_applet.dart';
import '../../features/visit_history/ui/visit_history_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';
import 'app_bar_title.dart';
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
/// - Outbox trigger: checks outbox on initial load and app resume.
class AppShellScreen extends StatefulWidget {
  final EmailDeliveryCoordinator? deliveryCoordinator;

  const AppShellScreen({super.key, this.deliveryCoordinator});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen>
    with WidgetsBindingObserver {
  late final EmailDeliveryCoordinator _deliveryCoordinator;
  final AppShellController _controller = AppShellController();
  final GlobalKey<ScaffoldState> _phoneScaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  bool _hasOpenedCombustion = false;

  @override
  void initState() {
    super.initState();
    _deliveryCoordinator =
        widget.deliveryCoordinator ?? EmailDeliveryCoordinator.instance;
    WidgetsBinding.instance.addObserver(this);
    _deliveryCoordinator.processOutbox();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _deliveryCoordinator.processOutbox();
    }
  }

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
    WidgetsBinding.instance.removeObserver(this);
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

            if (_controller.activeApplet == AppletType.combustion) {
              _hasOpenedCombustion = true;
            }

            final int bodyIndex;
            if (_controller.activeApplet == AppletType.home) {
              bodyIndex = 0;
            } else if (_controller.activeApplet == AppletType.combustion) {
              bodyIndex = 1;
            } else {
              bodyIndex = 2;
            }

            final Widget currentBody = IndexedStack(
              index: bodyIndex,
              children: [
                DashboardScreen(controller: _controller),
                _hasOpenedCombustion
                    ? VerbrandingsattestScreen(
                        key: ValueKey(_controller.visitGeneration),
                        controller: _controller)
                    : const SizedBox.shrink(),
                if (_controller.activeApplet == AppletType.history)
                  const VisitHistoryScreen()
                else if (_controller.activeApplet ==
                    AppletType.technicianSettings)
                  const TechnicianSettingsApplet()
                else
                  AppletContentPlaceholder(
                    appBarTitle: _controller.appBarTitle,
                    onBackToHome: () =>
                        _controller.selectApplet(AppletType.home),
                  ),
              ],
            );

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
                            FocusManager.instance.primaryFocus?.unfocus();
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
                  title: AppBarTitle(controller: _controller),
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
                        drawerEnableOpenDragGesture: false,
                        onDrawerChanged: (isOpen) {
                          if (isOpen) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
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
                            FocusManager.instance.primaryFocus?.unfocus();
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
}
