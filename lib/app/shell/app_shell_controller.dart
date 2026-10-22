import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';

/// Available applets and main sections in the HVAC application.
///
/// Add new applet entries here when expanding the app suite.
enum AppletType {
  home,
  combustion,
  cleaning,
  inspection,
  measurement,
}

/// Controller managing the persistent AppBar title and active navigation state.
///
/// Changes notified here update the persistent AppBar and Drawer highlight.
class AppShellController extends ChangeNotifier {
  AppletType _activeApplet = AppletType.home;

  /// The currently active applet or view.
  AppletType get activeApplet => _activeApplet;

  /// Returns the dynamic Dutch title to display in the persistent AppBar.
  String get appBarTitle {
    return switch (_activeApplet) {
      AppletType.home => AppDictionary.appTitle,
      AppletType.combustion => AppDictionary.menuCombustion,
      AppletType.cleaning => AppDictionary.menuCleaning,
      AppletType.inspection => AppDictionary.menuInspection,
      AppletType.measurement => AppDictionary.menuMeasurement,
    };
  }

  /// Selects an applet, updating the active view and dynamic AppBar title.
  void selectApplet(AppletType applet) {
    if (_activeApplet != applet) {
      _activeApplet = applet;
      notifyListeners();
    }
  }
}
