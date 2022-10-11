import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nyt_articles_viewer/screens/home_screen/home_screen.dart';

import 'models/tab_model.dart';

class MainLayoutWidget extends StatefulWidget {
  const MainLayoutWidget({super.key});

  @override
  State<MainLayoutWidget> createState() => _MainLayoutWidgetState();
}

class _MainLayoutWidgetState extends State<MainLayoutWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: appTabs[_currentIndex].relatedWidget,
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            items: appTabs.map((e) => e.bnbItem).toList(),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: colorScheme.brightness == Brightness.light
                ? colorScheme.onBackground
                : colorScheme.onBackground,
            unselectedItemColor: colorScheme.onBackground.withOpacity(.7),
            backgroundColor: colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}
