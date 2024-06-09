import 'package:flutter/material.dart';
import 'package:pillpal/src/navigation_bar.dart';

// TODO: falta toda a logica das notificações das cenas do arduino
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'lib/images/pillpal_image.png',
                height: 75,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text('No notifications yet!'),
      ),
      bottomNavigationBar: const NavBar(
        selectedIndex: 3,
      ),
    );
  }
}
