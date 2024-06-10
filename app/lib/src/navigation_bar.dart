import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;

  const NavBar({super.key, required this.selectedIndex});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void navigateToIndex(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home',
          arguments: {'selectedIndex': index});
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/search',
          arguments: {'selectedIndex': index});
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/calendar',
          arguments: {'selectedIndex': index});
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/alerts',
          arguments: {'selectedIndex': index});
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/user',
          arguments: {'selectedIndex': index});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2,
              child: const Icon(Icons.home_rounded),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2,
              child: const Icon(Icons.search_rounded),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2,
              child: const Icon(Icons.calendar_month_rounded),
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2,
              child: const Icon(Icons.notifications_none_rounded),
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2,
              child: const Icon(Icons.person_rounded),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.red.shade50,
        onTap: (value) {
          navigateToIndex(context, value);
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
