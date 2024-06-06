// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/MedicationDialog.dart';


class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: getCurrentWeekMedications(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Sem medicação'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data!.docs.map((doc) {
                    var med = doc.data();
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              med['Name'] + "_" + med['Dosage'].toString() + "mg",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            if (med['Description'] != null)
                              Text(med['Description']),
                            SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                Icon(Icons.notifications),
                                SizedBox(width: 8),
                                Text("Reminders"),
                              ],
                            ),
                            if (med['Reminders'] != null)
                              Text((med['Reminders'] as List<dynamic>).join(", ")),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AddMedicationDialog(
                                        medData: med,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

  Future<DocumentReference> addMedication(String name, String description, num dosage, List<String> days, List<String> reminders, String start, String finish) {
    return FirebaseFirestore.instance
        .collection('medication')
        .add(<String, dynamic>{
      'Name': name,
      'UserId': FirebaseAuth.instance.currentUser!.uid,
      'Description': description,
      'Dosage': dosage,
      'Days': days,
      'Reminders': reminders,
      'Start': start,
      'Finish': finish,
    });
  }

  DateTime getStartOfWeek() {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentDay - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  DateTime getEndOfWeek() {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    DateTime endOfWeek = now.add(Duration(days: 7 - currentDay));
    return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCurrentWeekMedications() async {
    DateTime startOfWeek = getStartOfWeek();
    DateTime endOfWeek = getEndOfWeek();

    return await FirebaseFirestore.instance
        .collection('medication')
        .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('Start', isGreaterThanOrEqualTo: startOfWeek)
        .where('Finish', isLessThanOrEqualTo: endOfWeek)
        .get();
  }