// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pillpal/medication_dialog.dart';
import 'package:pillpal/medication.dart';
import 'package:pillpal/navegation_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Week',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            'Your Medications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //TODO: make it so it's red on days the user has pills to take
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
              SvgPicture.asset('lib/images/graypillSvg.svg', height: 24),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('Mo'),
              Text('Tu'),
              Text('We'),
              Text('Th'),
              Text('Fr'),
              Text('Sa'),
              Text('Do'),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: MedicationPage(
              futureFunction: getCurrentWeekMedications,
            ),
          ),
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
      bottomNavigationBar: NavBar(),
    );
  }
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
