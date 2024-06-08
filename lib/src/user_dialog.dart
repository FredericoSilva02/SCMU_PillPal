import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDialog extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function()? onDialogClose;

  const UserDialog({super.key, this.userData, this.onDialogClose});

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodGroupController;
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.userData != null ? widget.userData!['Name'] : '');
    _contactController = TextEditingController(
        text: widget.userData != null ? widget.userData!['Contact'] : '');
    _addressController = TextEditingController(
        text: widget.userData != null ? widget.userData!['Address'] : '');
    _genderController = TextEditingController(
        text: widget.userData != null ? widget.userData!['Gender'] : '');
    _birthday = widget.userData != null
        ? (widget.userData!['Birthday'] as Timestamp).toDate()
        : null;
    _heightController = TextEditingController(
        text: widget.userData != null
            ? widget.userData!['Heigth'].toString()
            : '');
    _weightController = TextEditingController(
        text: widget.userData != null
            ? widget.userData!['Weight'].toString()
            : '');
    _bloodGroupController = TextEditingController(
        text: widget.userData != null
            ? widget.userData!['Blood Group'].toString()
            : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit medical info'),
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
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _bloodGroupController,
              decoration: const InputDecoration(labelText: 'Blood Group'),
            ),
            ListTile(
              title: Text(
                  "Birthday: ${_birthday != null ? _birthday!.toLocal().toString().split(' ')[0] : 'Select a date'}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String userId = FirebaseAuth.instance.currentUser!.uid;
            String name = _nameController.text;
            String contact = _contactController.text;
            String address = _addressController.text;
            String? email = FirebaseAuth.instance.currentUser!.email;
            String gender = _genderController.text;
            String bloodGroup = _bloodGroupController.text;
            num heigth = num.tryParse(_heightController.text) ?? 0;
            num weigth = num.tryParse(_weightController.text) ?? 0;
            Timestamp birthday = _birthday != null
                ? Timestamp.fromDate(_birthday!)
                : Timestamp.now();

            updateUser(userId, name, contact, address, email, gender,
                bloodGroup, heigth, weigth, birthday);
            Navigator.of(context).pop();
          },
          child: Text(widget.userData != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> updateUser(
      String userId,
      String name,
      String contact,
      String address,
      String? email,
      String gender,
      String bloodGroup,
      num heigth,
      num weigth,
      Timestamp birthday) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(<String, dynamic>{
      'Name': name,
      'Contact': contact,
      'Address': address,
      'Email': email,
      'Gender': gender,
      'Birthday': birthday,
      'Blood Group': bloodGroup,
      'Height': heigth,
      'Weight': weigth,
    });

    widget.onDialogClose?.call();
  }
}
