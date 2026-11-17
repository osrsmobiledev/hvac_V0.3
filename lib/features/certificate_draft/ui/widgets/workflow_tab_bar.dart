import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

class WorkflowTabBar extends StatelessWidget {
  const WorkflowTabBar({
    super.key,
    required this.controller,
    required this.titles,
  });

  final TabController controller;
  final List<String> titles;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF101010),
          border: Border(bottom: BorderSide(color: AppColors.goldHairline)),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: AppColors.amberGold, width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(2.5)),
            insets: EdgeInsets.only(bottom: 1.5),
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelColor: AppColors.amberGold,
          unselectedLabelColor: Colors.white,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
          ),
          tabs: titles.map((title) => Tab(height: 40, text: title)).toList(),
        ),
      );
}
