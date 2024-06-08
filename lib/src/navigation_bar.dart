import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void navigateToIndex(BuildContext context) {
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, '/search');
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacementNamed(context, '/calendar');
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacementNamed(context, '/user');
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
              scale: 1.2, // Increase scale for the home icon
              child: const Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2, // Increase scale for the search icon
              child: const Icon(Icons.search),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2, // Increase scale for the profile icon
              child: const Icon(Icons.calendar_month),
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.2, // Increase scale for the profile icon
              child: const Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        backgroundColor: Colors.red.shade50, // Light shade of red
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
            navigateToIndex(context);
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
