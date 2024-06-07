
// ignore_for_file: prefer_const_constructors, prefer_final_fields, library_private_types_in_public_api

import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void navigateToIndex(BuildContext context) {
    if (_selectedIndex == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_selectedIndex == 1) {
      Navigator.pushReplacementNamed(context, '/search');
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacementNamed(context, '/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'users',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          {
            _selectedIndex = value;
            navigateToIndex(context);  // Update _selectedIndex on tap
          }
        },
      ),
    );
  }
}