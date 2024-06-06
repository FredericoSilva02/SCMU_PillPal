// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pillpal/medication_dialog.dart';
import 'package:pillpal/medication.dart';

class PillInfoPage extends StatelessWidget {
  const PillInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 5),
          Expanded(
              child: MedicationPage(
            futureFunction: getAllMedication,
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddMedicationDialog();
            },
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

Future<QuerySnapshot<Map<String, dynamic>>> getAllMedication() async {
  return await FirebaseFirestore.instance
      .collection('medication')
      .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
}
