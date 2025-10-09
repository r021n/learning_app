// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class MainScaffold extends StatelessWidget {
//   final Widget child;

//   const MainScaffold({required this.child, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: child,
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Materi'),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
//         ],
//         currentIndex: _calculateSelectedIndex(context),
//         onTap: (int index) => _onItemTapped(index, context),
//       ),
//     );
//   }

//   static int _calculateSelectedIndex(BuildContext context) {
//     final String location = GoRouterState.of(context).matchedLocation;
//     if (location.startsWith('/home')) {
//       return 0;
//     }

//     if (location.startsWith('/history')) {
//       return 1;
//     }

//     return 0;
//   }

//   void _onItemTapped(int index, BuildContext context) {
//     switch (index) {
//       case 0:
//         context.go('/home');
//         break;
//       case 1:
//         context.go('/history');
//         break;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculatedSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.school),
            icon: Icon(Icons.school_outlined),
            label: 'Materi',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  static int _calculatedSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/history')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/history');
        break;
    }
  }
}
