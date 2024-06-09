import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pillpal/src/user_dialog.dart';
import 'package:intl/intl.dart';

class UserInfoCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function()? onDialogClose;

  const UserInfoCard({super.key, required this.userData, this.onDialogClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userData['Name']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUserInfoRow('Gender', userData['Gender']),
                _buildUserInfoRow(
                    'Birthday',
                    DateFormat('dd-MM-yyyy')
                        .format(userData['Birthday'].toDate())),
                _buildUserInfoRow('Height', userData['Height'].toString()),
                _buildUserInfoRow('Weight', userData['Weight'].toString()),
                _buildUserInfoRow('Blood Group', userData['Blood Group']),
                const SizedBox(height: 16),
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildUserInfoRow('Name', userData['Name']),
                _buildUserInfoRow('Contact', userData['Contact']),
                _buildUserInfoRow('Address', userData['Address']),
                _buildUserInfoRow('Email', userData['Email']),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return UserDialog(
                              userData: userData,
                              onDialogClose: onDialogClose,
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value != null ? value.toString() : 'N/A'),
      ],
    );
  }

  // ! TODO
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

Future<QuerySnapshot<Map<String, dynamic>>> getCareTakerInfo(
    String caretakerId) async {
  return await FirebaseFirestore.instance
      .collection('users')
      .where('Name', isEqualTo: caretakerId)
      .get();
}
