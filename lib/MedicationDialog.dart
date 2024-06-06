import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMedicationDialog extends StatelessWidget {
  final Map<String, dynamic>? medData; // Optional medication data
  final String? id;

  const AddMedicationDialog({super.key, this.medData, this.id});

  @override
  Widget build(BuildContext context) {
    // Initialize fields with medication data if available
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String name = medData != null ? medData!['Name'] : '';
    String description = medData != null ? medData!['Description'] : '';
    num dosage = medData != null ? medData!['Dosage'] : 0;
    List<dynamic> days = medData != null ? medData!['Days'] : [];
    List<dynamic> reminders = medData != null ? medData!['Reminders'] : [];
    Timestamp start = medData != null ? medData!['Start'] : Timestamp.fromDate(DateTime.now());
    Timestamp finish = medData != null ? medData!['Finish'] : Timestamp.fromDate(DateTime.now());

    return AlertDialog(
      title: Text(medData != null ? 'Edit Medication' : 'Add Medication'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: name),
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                name = value;
              },
            ),
            TextField(
              controller: TextEditingController(text: description),
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            TextField(
              controller: TextEditingController(text: dosage.toString()),
              decoration: InputDecoration(labelText: 'Dosage in miligrams'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                dosage = value as num;
              },
            ),
            TextField(
              controller: TextEditingController(text: (days as List<dynamic>).join(", ")),
              decoration: InputDecoration(labelText: 'Week days'),
              onChanged: (value) {
                days = value.split(",".trim());
              },
            ),
            TextField(
              controller: TextEditingController(text: (reminders as List<dynamic>).join(", ")),
              decoration: InputDecoration(labelText: 'Hour reminders'),
              onChanged: (value) {
                reminders = value.split(",".trim());
              },
            ),
            TextField(
              controller: TextEditingController(text: start.toDate().toUtc().day.toString()),
              decoration: InputDecoration(labelText: 'Starting date'),
              onChanged: (value) {
                start = DateTime.utc(value as int) as Timestamp;
              },
            ),
            TextField(
              controller: TextEditingController(text: finish.toDate().toUtc().day.toString()),
              decoration: InputDecoration(labelText: 'Finishing date'),
              onChanged: (value) {
                finish = DateTime.utc(value as int) as Timestamp;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (medData != null) {
              updateMedication(userId, name, description, dosage, days, reminders, start, finish);
            } else {
              createMedication(userId, name, description, dosage, days, reminders, start, finish);
            }
            Navigator.of(context).pop();
          },
          child: Text(medData != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

void createMedication(String userId, String name, String description, num dosage, List<dynamic> days, List<dynamic> reminders, Timestamp start, Timestamp finish) {
  String id = "${name}_${dosage}mg";
  FirebaseFirestore.instance
    .collection('medication')
    .doc(id)
    .set(<String, dynamic>{
      'Name': name,
      'UserId': userId,
      'Description': description,
      'Dosage': dosage,
      'Days': days,
      'Reminders': reminders,
      'Start': start,
      'Finish': finish,
    });
}

  void updateMedication(String userId, String name, String description, num dosage, List<dynamic> days, List<dynamic> reminders, Timestamp start, Timestamp finish) {
  FirebaseFirestore.instance
    .collection('medication')
    .doc(id)
    .update(<String, dynamic>{
      'Name': name,
      'UserId': userId,
      'Description': description,
      'Dosage': dosage,
      'Days': days,
      'Reminders': reminders,
      'Start': start,
      'Finish': finish,
    });
}
}
