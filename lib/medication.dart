// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/medication_dialog.dart';

class MedicationPage extends StatelessWidget {
  final Future<QuerySnapshot<Map<String, dynamic>>> Function() futureFunction;

  const MedicationPage({super.key, required this.futureFunction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: futureFunction(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                              style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                              Text((med['Reminders'] as List<dynamic>)
                                  .join(", ")),
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
                                        id: doc.id,
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
