import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMedicationDialog extends StatefulWidget {
  final Map<String, dynamic>? medData;
  final String? id;
  final Function() onDialogClose;

  const AddMedicationDialog(
      {super.key, this.medData, this.id, required this.onDialogClose});

  @override
  _AddMedicationDialogState createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dosageController;
  late TextEditingController _remindersController;
  late TextEditingController _startDateController;
  late TextEditingController _finishDateController;
  List<bool> _selectedDays = List.filled(7, false);

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
    _remindersController = TextEditingController(
        text: widget.medData != null
            ? (widget.medData!['Reminders'] as List<dynamic>).join(", ")
            : '');
    _startDateController = TextEditingController(
        text: widget.medData != null
            ? (widget.medData!['Start'] as Timestamp)
                .toDate()
                .toLocal()
                .toString()
                .split(' ')[0]
            : '');
    _finishDateController = TextEditingController(
        text: widget.medData != null
            ? (widget.medData!['Finish'] as Timestamp)
                .toDate()
                .toLocal()
                .toString()
                .split(' ')[0]
            : '');

    if (widget.medData != null && widget.medData!['Days'] != null) {
      List<int> days = (widget.medData!['Days'] as List<dynamic>).cast<int>();
      for (int day in days) {
        _selectedDays[day] = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _remindersController.dispose();
    _startDateController.dispose();
    _finishDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.medData != null ? 'Edit Medication' : 'Add Medication',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          if (widget.medData != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 30,
              ),
              onPressed: () {
                _deleteMedication();
              },
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dosageController,
              decoration:
                  const InputDecoration(labelText: 'Dosage in milligrams'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text('Week days:'),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildDayToggle('Mon', 0),
                _buildDayToggle('Tue', 1),
                _buildDayToggle('Wed', 2),
                _buildDayToggle('Thu', 3),
                _buildDayToggle('Fri', 4),
                _buildDayToggle('Sat', 5),
                _buildDayToggle('Sun', 6),
              ],
            ),
            TextField(
              controller: _remindersController,
              decoration: const InputDecoration(labelText: 'Hour reminders'),
            ),
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Starting date',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
            ),
            TextField(
              controller: _finishDateController,
              decoration: const InputDecoration(
                labelText: 'Finishing date',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _finishDateController),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            String userId = FirebaseAuth.instance.currentUser!.uid;
            String name = _nameController.text;
            String description = _descriptionController.text;
            num dosage = num.tryParse(_dosageController.text) ?? 0;
            List<int> days = [];
            for (int i = 0; i < _selectedDays.length; i++) {
              if (_selectedDays[i]) {
                days.add(i);
              }
            }
            List<String> reminders = _remindersController.text
                .split(',')
                .map((e) => e.trim())
                .toList();
            Timestamp start =
                Timestamp.fromDate(DateTime.parse(_startDateController.text));
            Timestamp finish =
                Timestamp.fromDate(DateTime.parse(_finishDateController.text));

            if (widget.medData != null) {
              updateMedication(userId, name, description, dosage, days,
                  reminders, start, finish);
            } else {
              createMedication(userId, name, description, dosage, days,
                  reminders, start, finish);
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.medData != null ? 'Update' : 'Create',
              style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildDayToggle(String label, int index) {
    BorderRadius borderRadius;
    if (index == 0) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      );
    } else if (index == 6) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      );
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDays[index] = !_selectedDays[index];
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: _selectedDays[index] ? Colors.red : Colors.transparent,
            border: Border.all(color: Colors.red),
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _selectedDays[index] ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createMedication(
      String userId,
      String name,
      String description,
      num dosage,
      List<int> days,
      List<dynamic> reminders,
      Timestamp start,
      Timestamp finish) async {
    await FirebaseFirestore.instance
        .collection('medication')
        .add(<String, dynamic>{
      'Name': name,
      'UserId': userId,
      'Description': description,
      'Dosage': dosage,
      'Days': days,
      'Reminders': reminders,
      'Start': start,
      'Finish': finish,
    });

    widget.onDialogClose.call();
  }

  Future<void> updateMedication(
      String userId,
      String name,
      String description,
      num dosage,
      List<int> days,
      List<dynamic> reminders,
      Timestamp start,
      Timestamp finish) async {
    await FirebaseFirestore.instance
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

    widget.onDialogClose.call();
  }

  Future<void> _deleteMedication() async {
    if (widget.id != null) {
      await FirebaseFirestore.instance
          .collection('medication')
          .doc(widget.id)
          .delete();
      widget.onDialogClose.call();
      Navigator.of(context).pop();
    }
  }
}
