// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/src/medication_dialog.dart';
import 'package:pillpal/src/medication_card.dart';
import 'package:pillpal/src/navegation_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  void _reloadPage(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => this));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Expanded(
            child: MedicationPage(
              futureFunction: getAllMedication,
              onDialogClose: () {
                _reloadPage(context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddMedicationDialog(
                onDialogClose: () {
                  _reloadPage(context);
                },
              );
            },
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}

Future<QuerySnapshot<Map<String, dynamic>>> getAllMedication() async {
  return await FirebaseFirestore.instance
      .collection('medication')
      .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
}
