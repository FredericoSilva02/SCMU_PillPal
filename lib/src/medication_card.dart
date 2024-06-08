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
                children: snapshot.data!.docs.map((document) {
                  var medicationData = document.data();
                  return _buildMedicationCard(
                      context, medicationData, document.id);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context,
      Map<String, dynamic> medicationData, String documentId) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: Colors.red.shade50,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    medicationData['Name'],
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${medicationData['Dosage']} mg',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  if (medicationData['Description'] != null &&
                      medicationData['Description'] != '') ...[
                    const SizedBox(height: 10),
                    Text(medicationData['Description']),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    "Days",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (medicationData['Days'] != null)
                    Text(_convertDaysToString(
                        medicationData['Days'] as List<dynamic>)),
                  const SizedBox(height: 10),
                  const Text(
                    "Reminders",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (medicationData['Reminders'] != null)
                    Text((medicationData['Reminders'] as List<dynamic>)
                        .join(", ")),
                ],
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AddMedicationDialog(
                        medData: medicationData,
                        id: documentId,
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
  }

  String _convertDaysToString(List<dynamic> days) {
    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return days.map((day) => dayNames[day as int]).join(", ");
  }
}
