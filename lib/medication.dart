// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/LoginPage.dart';


class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getMedication(String id) async {
    var x = FirebaseFirestore.instance
        .collection('medication')
        .doc('Aspirina_1000mg')
        .get();

    return x;
  }

 @override
Widget build(BuildContext context) {
return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getMedication(FirebaseAuth.instance.currentUser!.uid),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Sem medicação'));
        } else {
          var med = snapshot.data!.data();

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    med?['Name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (med?['Description'] != null)
                    Text(med?['Description']),
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Icon(Icons.notifications),
                      SizedBox(width: 8),
                      Text("Reminders"),
                    ],
                  ),
                  if (med?['Reminders'] != null)
                    Text(med?['Reminders']!.join(", ")),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

  Future<DocumentReference> addMedication(String name, String description, num dosage, List<String> days, List<String> reminders, String start, String finish) {
    return FirebaseFirestore.instance
        .collection('medication')
        .add(<String, dynamic>{
      'Name': name,
      'Description': description,
      'Dosage': dosage,
      'Days': days,
      'Reminders': reminders,
      'Start': start,
      'Finish': finish,
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMedication(String id) async {
  var x = FirebaseFirestore.instance
    .collection('medication')
    .doc('Aspirina_1000mg')
    .get();

    return x;
  }
  
  
  class Medication {
  final String name;
  final num? dosage;
  final String? description;
  final String? start;
  final String? finish;
  final List<String>? reminders;
  final List<String>? days;

  Medication({
    required this.name,
    this.description,
    this.reminders,
    this.days,
    this.dosage,
    this.start,
    this.finish,
  });
}