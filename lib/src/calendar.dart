import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/src/navigation_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _medicationEvents = {};

  @override
  void initState() {
    super.initState();
    _fetchMedicationEvents();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendar',
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2040, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _getEventsForDay(day);
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2.0),
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
                todayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2.0),
                    ),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView(
                children: _getEventsForDay(_selectedDay)
                    .map((medication) =>
                        CustomEventItem(eventDetail: medication))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(
        selectedIndex: 2,
      ),
    );
  }

  Future<void> _fetchMedicationEvents() async {
    try {
      QuerySnapshot medications = await FirebaseFirestore.instance
          .collection('medication')
          .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      Map<DateTime, List<String>> events = {};

      for (var doc in medications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = data['Name'];
        List<int> days = List<int>.from(data['Days']);
        List<dynamic> reminders = data['Reminders'];
        DateTime start = (data['Start'] as Timestamp).toDate();
        DateTime finish = (data['Finish'] as Timestamp).toDate();

        for (DateTime date = start;
            date.isBefore(finish) || date.isAtSameMomentAs(finish);
            date = date.add(const Duration(days: 1))) {
          if (days.contains(date.weekday % 7)) {
            for (var reminder in reminders) {
              DateTime reminderTime;

              // Check the type of reminder and parse accordingly
              if (reminder is Timestamp) {
                reminderTime = reminder.toDate();
              } else if (reminder is String) {
                // Assuming the string is in "HH:mm" format
                List<String> parts = reminder.split(':');
                int hour = int.parse(parts[0]);
                int minute = int.parse(parts[1]);
                reminderTime =
                    DateTime(date.year, date.month, date.day, hour, minute);
              } else {
                continue; // Skip if the type is not handled
              }

              String eventDetail =
                  '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')} - $name';

              DateTime normalizedDate = _normalizeDate(date);

              if (!events.containsKey(normalizedDate)) {
                events[normalizedDate] = [];
              }
              events[normalizedDate]!.add(eventDetail);
            }
          }
        }
      }

      events.forEach((date, eventList) {
        eventList.sort((a, b) {
          List<String> partsA = a.split(' - ')[0].split(':');
          List<String> partsB = b.split(' - ')[0].split(':');
          DateTime timeA =
              DateTime(0, 1, 1, int.parse(partsA[0]), int.parse(partsA[1]));
          DateTime timeB =
              DateTime(0, 1, 1, int.parse(partsB[0]), int.parse(partsB[1]));
          return timeA.compareTo(timeB);
        });
      });

      setState(() {
        _medicationEvents = events;
      });

      print('Medication Events: $_medicationEvents');
    } catch (e) {
      print('Error fetching medication events: $e');
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = _normalizeDate(day);
    return _medicationEvents[normalizedDay] ?? [];
  }
}

class CustomEventItem extends StatelessWidget {
  final String eventDetail;

  const CustomEventItem({Key? key, required this.eventDetail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(3),
            ),
            margin: const EdgeInsets.only(right: 8.0),
          ),
          Expanded(
            child: Text(
              eventDetail,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
