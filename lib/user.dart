// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pillpal/user_dialog.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical info',
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
              ),
            ),
            Image.asset(
              'lib/images/pillpal_image.png',
              height: 60,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: getUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No user data found'));
          } else {
            var userData = snapshot.data!.docs.first.data();
            return UserInfoCard(userData: userData);
          }
        },
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${userData['Name']}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildUserInfoRow('Gender', userData['Gender']),
              _buildUserInfoRow('Birthday', userData['birthday']),
              _buildUserInfoRow('Height', userData['Height'].toString()),
              _buildUserInfoRow('Weight', userData['Weigth'].toString()),
              _buildUserInfoRow('Blood Group', userData['Blood Group']),
              SizedBox(height: 16),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              _buildEmergencyContacts(userData),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return UserDialog(
                            userData: userData,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildUserInfoRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value != null ? value.toString() : 'N/A'),
      ],
    );
  }

  Widget _buildEmergencyContacts(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(userData['Name'] ?? 'N/A'),
        Text(userData['Contact'] ?? 'N/A'),
        Text(userData['Address'] ?? 'N/A'),
        Text(userData['Email'] ?? 'N/A'),
      ],
    );
  }
}

//TODO change to userId, create User in SignUp
Future<QuerySnapshot<Map<String, dynamic>>> getUserInfo() async {
  String? email = FirebaseAuth.instance.currentUser?.email;
  return await FirebaseFirestore.instance
      .collection('users')
      .where('Email', isEqualTo: email)
      .get();
}

Future<QuerySnapshot<Map<String, dynamic>>> getCareTakerInfo(String caretakerId) async {
  return await FirebaseFirestore.instance
      .collection('users')
      .where('Name', isEqualTo: caretakerId)
      .get();
}
