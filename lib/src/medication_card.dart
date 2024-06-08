import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/src/medication_dialog.dart';

class MedicationPage extends StatelessWidget {
  final Future<QuerySnapshot<Map<String, dynamic>>> Function() futureFunction;
  final Function() onDialogClose;

  const MedicationPage(
      {super.key, required this.futureFunction, required this.onDialogClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: futureFunction(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No medication for this week :)'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  var med = doc.data();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            med['Name'] + "_" + med['Dosage'].toString() + "mg",
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          if (med['Description'] != null)
                            Text(med['Description']),
                          const SizedBox(height: 10),
                          const Row(
                            children: <Widget>[
                              Icon(Icons.notifications),
                              SizedBox(width: 10),
                              Text("Reminders"),
                            ],
                          ),
                          if (med['Reminders'] != null)
                            Text(
                                (med['Reminders'] as List<dynamic>).join(", ")),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddMedicationDialog(
                                      medData: med,
                                      id: doc.id,
                                      onDialogClose: onDialogClose,
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
            );
          }
        },
      ),
    );
  }
}
