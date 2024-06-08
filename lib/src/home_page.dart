import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pillpal/src/medication_dialog.dart';
import 'package:pillpal/src/medication_card.dart';
import 'package:pillpal/src/navegation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<int, bool>> _medicationDays;

  @override
  void initState() {
    super.initState();
    _loadMedicationDays();
  }

  void _loadMedicationDays() {
    setState(() {
      _medicationDays = _getMedicationDays();
    });
  }

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
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              'lib/images/pillpal_image.png',
              height: 75,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<int, bool>>(
        future: _medicationDays,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading medications'));
          } else {
            Map<int, bool>? medicationDays = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayColumn('Mo', medicationDays?[0] ?? false),
                    _buildDayColumn('Tu', medicationDays?[1] ?? false),
                    _buildDayColumn('We', medicationDays?[2] ?? false),
                    _buildDayColumn('Th', medicationDays?[3] ?? false),
                    _buildDayColumn('Fr', medicationDays?[4] ?? false),
                    _buildDayColumn('Sa', medicationDays?[5] ?? false),
                    _buildDayColumn('Su', medicationDays?[6] ?? false),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: MedicationPage(
                    futureFunction: _getCurrentWeekMedications,
                    onDialogClose: () {
                      _loadMedicationDays();
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddMedicationDialog(
                onDialogClose: () {
                  _loadMedicationDays();
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

  Widget _buildDayColumn(String day, bool hasMedication) {
    return Column(
      children: [
        SvgPicture.asset(
          hasMedication ? 'lib/images/redpill.svg' : 'lib/images/greypill.svg',
          height: 30,
        ),
        Text(day),
      ],
    );
  }
}

DateTime _getStartOfFixedWeek(DateTime date) {
  int daysToSubtract = date.weekday - DateTime.monday;
  if (daysToSubtract < 0) {
    daysToSubtract += 7;
  }
  return DateTime(date.year, date.month, date.day)
      .subtract(Duration(days: daysToSubtract));
}

DateTime _getEndOfFixedWeek(DateTime date) {
  DateTime startOfWeek = _getStartOfFixedWeek(date);
  return startOfWeek.add(Duration(
      days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
}

Future<Map<int, bool>> _getMedicationDays() async {
  Map<int, bool> medicationDays = {for (int i = 0; i < 7; i++) i: false};

  QuerySnapshot<Map<String, dynamic>> snapshot =
      await _getCurrentWeekMedications();

  DateTime startOfWeek = _getStartOfFixedWeek(DateTime.now());

  for (var doc in snapshot.docs) {
    List<dynamic> days = doc[
        'Days']; // Assuming 'Days' is a list of integers representing the weekdays (0 for Monday, ..., 6 for Sunday)
    Timestamp startTimestamp = doc['Start'];
    Timestamp finishTimestamp = doc['Finish'];
    DateTime startDate = startTimestamp.toDate();
    DateTime finishDate = finishTimestamp.toDate();

    for (int day in days) {
      if (day == 7) {
        // Adjusting old data if Sunday is represented as 7
        day = 0; // Map Sunday (7) to 0
      }

      DateTime currentDay = startOfWeek.add(Duration(days: day));

      if ((startDate.isBefore(currentDay) ||
              startDate.isAtSameMomentAs(currentDay)) &&
          (finishDate.isAfter(currentDay) ||
              finishDate.isAtSameMomentAs(currentDay))) {
        medicationDays[day] = true;
      }
    }
  }
  return medicationDays;
}

Future<QuerySnapshot<Map<String, dynamic>>> _getCurrentWeekMedications() async {
  DateTime startOfWeek = _getStartOfFixedWeek(DateTime.now());
  DateTime endOfWeek = _getEndOfFixedWeek(DateTime.now());

  return await FirebaseFirestore.instance
      .collection('medication')
      .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('Start', isLessThanOrEqualTo: endOfWeek)
      .where('Finish', isGreaterThanOrEqualTo: startOfWeek)
      .get();
}
