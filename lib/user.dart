// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

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
            return Padding(
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
                        '${userData['firstName']} ${userData['lastName']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildUserInfoRow('Gender', userData['gender']),
                      _buildUserInfoRow('Birthday', userData['birthday']),
                      _buildUserInfoRow('Height', userData['height']),
                      _buildUserInfoRow('Weight', userData['weight']),
                      _buildUserInfoRow('Blood Group', userData['bloodGroup']),
                      SizedBox(height: 16),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData['name']),
                            Text(userData['phone']),
                            Text(userData['address']),
                            Text(userData['email']),
                          ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.mail),
                            onPressed: () {
                              // Handle email action
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildContactInfo(Map<String, dynamic> contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(contact['name']),
        Text(contact['phone']),
        Text(contact['address']),
        Text(contact['email']),
      ],
    );
  }
}


//TODO change to userId, create User in SignUp
Future<QuerySnapshot<Map<String, dynamic>>> getUserInfo() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
}

Future<QuerySnapshot<Map<String, dynamic>>> getCareTakerInfo(String caretakerId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('Name', isEqualTo: caretakerId)
        .get();
}


  