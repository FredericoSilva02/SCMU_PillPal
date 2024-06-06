import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMedicationDialog extends StatefulWidget {
  final Map<String, dynamic>? medData; // Optional medication data
  final String? id;

  const AddMedicationDialog({super.key, this.medData, this.id});

  @override
  _AddMedicationDialogState createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dosageController;
  late TextEditingController _daysController;
  late TextEditingController _remindersController;
  DateTime? _startDate;
  DateTime? _finishDate;

  @override
  void initState() {
    super.initState();
    // Initialize fields with medication data if available
    _nameController = TextEditingController(
        text: widget.medData != null ? widget.medData!['Name'] : '');
    _descriptionController = TextEditingController(
        text: widget.medData != null ? widget.medData!['Description'] : '');
    _dosageController = TextEditingController(
        text:
            widget.medData != null ? widget.medData!['Dosage'].toString() : '');
    _daysController = TextEditingController(
        text: widget.medData != null
            ? (widget.medData!['Days'] as List<dynamic>).join(", ")
            : '');
    _remindersController = TextEditingController(
        text: widget.medData != null
            ? (widget.medData!['Reminders'] as List<dynamic>).join(", ")
            : '');
    _startDate = widget.medData != null
        ? (widget.medData!['Start'] as Timestamp).toDate()
        : null;
    _finishDate = widget.medData != null
        ? (widget.medData!['Finish'] as Timestamp).toDate()
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _daysController.dispose();
    _remindersController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _finishDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _finishDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.medData != null ? 'Edit Medication' : 'Add Medication'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dosageController,
              decoration: InputDecoration(labelText: 'Dosage in milligrams'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _daysController,
              decoration: InputDecoration(labelText: 'Week days'),
            ),
            TextField(
              controller: _remindersController,
              decoration: InputDecoration(labelText: 'Hour reminders'),
            ),
            ListTile(
              title: Text(
                  "Starting date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Select a date'}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(
                  "Finishing date: ${_finishDate != null ? _finishDate!.toLocal().toString().split(' ')[0] : 'Select a date'}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
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
            String userId = FirebaseAuth.instance.currentUser!.uid;
            String name = _nameController.text;
            String description = _descriptionController.text;
            num dosage = num.tryParse(_dosageController.text) ?? 0;
            List<String> days =
                _daysController.text.split(',').map((e) => e.trim()).toList();
            List<String> reminders = _remindersController.text
                .split(',')
                .map((e) => e.trim())
                .toList();
            Timestamp start = _startDate != null
                ? Timestamp.fromDate(_startDate!)
                : Timestamp.now();
            Timestamp finish = _finishDate != null
                ? Timestamp.fromDate(_finishDate!)
                : Timestamp.now();

            if (widget.medData != null) {
              updateMedication(userId, name, description, dosage, days,
                  reminders, start, finish);
            } else {
              createMedication(userId, name, description, dosage, days,
                  reminders, start, finish);
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.medData != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void createMedication(
      String userId,
      String name,
      String description,
      num dosage,
      List<dynamic> days,
      List<dynamic> reminders,
      Timestamp start,
      Timestamp finish) {
    FirebaseFirestore.instance.collection('medication').add(<String, dynamic>{
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

  void updateMedication(
      String userId,
      String name,
      String description,
      num dosage,
      List<dynamic> days,
      List<dynamic> reminders,
      Timestamp start,
      Timestamp finish) {
    FirebaseFirestore.instance
        .collection('medication')
        .doc(widget.id)
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
