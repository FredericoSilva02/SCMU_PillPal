import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpal/src/navigation_bar.dart';
import 'package:pillpal/src/user_card.dart';

class MediacalInfoPage extends StatelessWidget {
  const MediacalInfoPage({super.key});

  void _reloadPage(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => this));
  }

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
                'Medical info',
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: getUserInfo(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No user data found'));
            } else {
              var userData = snapshot.data!.docs.first.data();
              return UserInfoCard(
                userData: userData,
                onDialogClose: () {
                  _reloadPage(context);
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const NavBar(
        selectedIndex: 4,
      ),
    );
  }
}
