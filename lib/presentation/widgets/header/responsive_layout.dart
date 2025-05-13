// import 'package:flow/presentation/widgets/drawer_menu/drawer_menu.dart';
// import 'package:flow/presentation/widgets/side_bar/side_bar.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:responsive_framework/responsive_framework.dart';

// class ResponsiveLayout extends StatelessWidget {
//   final Widget child;

//   const ResponsiveLayout({super.key, required this.child});

//   static final tabs = ['/home', '/profile', '/settings'];

//   @override
//   Widget build(BuildContext context) {

//     final currentLocation = GoRouterState.of(context).uri.toString();
//     int selectedIndex = tabs.indexWhere((tab) => currentLocation.startsWith(tab));
//     selectedIndex = selectedIndex == -1 ? 0 : selectedIndex;

//     final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
//     final isMobile = ResponsiveBreakpoints.of(context).isMobile;

//     return Scaffold(
//       appBar: isDesktop
//           ? null
//           : AppBar(
//               title: const Text('Flow'),
//               leading: Builder(
//                 builder: (context) => IconButton(
//                   icon: const Icon(Icons.menu),
//                   onPressed: () => Scaffold.of(context).openDrawer(),
//                 ),
//               ),
//             ),
//       drawer: isDesktop ? null : const DrawerMenu(),
//       drawerEnableOpenDragGesture: !kIsWeb && isMobile,
//       body: Row(
//         children: [
//           if (isDesktop) const SidebarMenu(),
//           Expanded(child: child),
//         ],
//       ),
//     );

//     // return Scaffold(
//     //   appBar: isDesktop ? null : AppBar(
//     //     title: const Text('Flow'),
//     //     leading: Builder(
//     //       builder: (context) => IconButton(
//     //         icon: const Icon(Icons.menu),
//     //         onPressed: () => Scaffold.of(context).openDrawer(),
//     //       ),
//     //     ),
//     //   ),
//     //   drawer: isDesktop ? null : const DrawerMenu(),

//     //   drawerEnableOpenDragGesture: !kIsWeb && isMobile,
//     //   body: Row(
//     //     children: [
//     //       if (isDesktop) const SidebarMenu(),
//     //       Expanded(child: child),
//     //     ],
//     //   ),
//     // );
//   }
// }

import 'package:flow/presentation/widgets/drawer_menu/drawer_menu.dart';
import 'package:flow/presentation/widgets/side_bar/side_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveLayout({super.key, required this.child});

  static final tabs = ['/', '/profile', '/settings'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Находим точное соответствие без путаницы
    int selectedIndex = tabs.indexWhere((tab) => location == tab);
    selectedIndex = selectedIndex == -1 ? 0 : selectedIndex;

    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // appBar: isDesktop
      //     ? null
      //     : AppBar(
      //         backgroundColor: const Color(0xFF1F1F1F),
      //         title: const Text('Flow'),
      //         leading: Builder(
      //           builder: (context) => IconButton(
      //             icon: const Icon(Icons.menu),
      //             onPressed: () => Scaffold.of(context).openDrawer(),
      //           ),
      //         ),
      //       ),
      drawer: isDesktop ? null : const DrawerMenu(),
      drawerEnableOpenDragGesture: !kIsWeb && isMobile,
      body: Row(
        children: [
          if (isDesktop) const SidebarMenu(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                backgroundColor: const Color(0xFF1A1A1A),
                currentIndex: selectedIndex,
                selectedItemColor: const Color(0xFF4CAF50),
                unselectedItemColor: Colors.grey[500],
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: false,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                onTap: (index) {
                  if (index != selectedIndex) {
                    context.go(tabs[index]);
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
