// File: lib/core/widgets/tactical_tab_bar_view.dart
// Responsibility: High-performance TabBarView replacement with true viewport pre-caching.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// High-performance drop-in replacement for [TabBarView] that pre-renders
/// and caches all workflow tabs into the GPU viewport cache.
///
/// Prevents the first-switch frame drops / jank by configuring:
/// - [allowImplicitScrolling] = true
/// - [scrollCacheExtent] = viewport(tabCount)
///
/// This ensures every tab in the workflow is already mounted, laid out,
/// and warm in memory before the user swipes or taps into it.
class TacticalTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  final ScrollPhysics? physics;

  const TacticalTabBarView({
    super.key,
    required this.controller,
    required this.children,
    this.physics,
  });

  @override
  State<TacticalTabBarView> createState() => _TacticalTabBarViewState();
}

class _TacticalTabBarViewState extends State<TacticalTabBarView> {
  late final PageController _pageController;
  bool _isUserDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.index);
    widget.controller.addListener(_handleTabControllerTick);
  }

  @override
  void didUpdateWidget(covariant TacticalTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTabControllerTick);
      widget.controller.addListener(_handleTabControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabControllerTick);
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabControllerTick() {
    if (_isUserDragging || !_pageController.hasClients) return;
    final target = widget.controller.index;
    if (_pageController.page?.round() != target) {
      FocusManager.instance.primaryFocus?.unfocus();
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.controller.index != index) {
      widget.controller.animateTo(index);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _isUserDragging = true;
    } else if (notification is ScrollEndNotification) {
      _isUserDragging = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: PageView(
        controller: _pageController,
        physics: widget.physics ?? const BouncingScrollPhysics(),
        allowImplicitScrolling: true,
        scrollCacheExtent: ScrollCacheExtent.viewport(count.toDouble()),
        onPageChanged: _onPageChanged,
        children: [
          for (final child in widget.children)
            FocusScope(
              child: child,
            ),
        ],
      ),
    );
  }
}
