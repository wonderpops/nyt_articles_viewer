import 'package:flutter/material.dart';

import '../screens/home_screen/home_screen.dart';

class AppTab {
  final BottomNavigationBarItem bnbItem;
  final Widget relatedWidget;

  AppTab({required this.bnbItem, required this.relatedWidget});
}

List<AppTab> appTabs = [
  AppTab(
    bnbItem: const BottomNavigationBarItem(
      icon: Icon(Icons.home_filled),
      label: 'Home',
    ),
    relatedWidget: const HomeScreenWidget(),
  ),
  AppTab(
    bnbItem: const BottomNavigationBarItem(
      icon: Icon(Icons.star_rate_rounded),
      label: 'Favorites',
    ),
    relatedWidget: const HomeScreenWidget(),
  ),
  AppTab(
    bnbItem: const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    relatedWidget: const HomeScreenWidget(),
  ),
];
