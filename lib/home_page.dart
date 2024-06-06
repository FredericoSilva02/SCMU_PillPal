// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pillpal/medication.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Week',
              style: TextStyle(
                fontSize: 48, // Set the desired font size
                fontWeight: FontWeight.bold, // Optionally set the font weight
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
              //TODO: make it soo its red on days the user has pills to take
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
          Expanded(child: MedicationPage())
        ],
      ),
    );
  }
}
