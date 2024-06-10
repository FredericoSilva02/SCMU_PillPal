import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillpal/src/medication_dialog.dart';
import 'package:pillpal/src/medication_card.dart';
import 'package:pillpal/src/navigation_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  late Future<QuerySnapshot<Map<String, dynamic>>> _medicationsFuture;

  @override
  void initState() {
    super.initState();
    _medicationsFuture = getAllMedication();
  }

  void _reloadPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const SearchPage()),
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _medicationsFuture = getAllMedication(query: _searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          // padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                onChanged: _updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search medication...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    borderSide: BorderSide(
                      color: Colors.red.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    borderSide: BorderSide(
                      color: Colors.red.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    borderSide: BorderSide(
                      color: Colors.red.shade300,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: MedicationPage(
                isHomePage: false,
                futureFunction: () => _medicationsFuture,
                onDialogClose: () {
                  _reloadPage(context);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddMedicationDialog(
                onDialogClose: () {
                  _reloadPage(context);
                },
              );
            },
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const NavBar(
        selectedIndex: 1,
      ),
    );
  }
}

Future<QuerySnapshot<Map<String, dynamic>>> getAllMedication(
    {String query = ''}) async {
  if (query.isEmpty) {
    return await FirebaseFirestore.instance
        .collection('medication')
        .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
  } else {
    return await FirebaseFirestore.instance
        .collection('medication')
        .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('Name', isGreaterThanOrEqualTo: query)
        .where('Name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }
}
