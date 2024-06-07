// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:pillpal/User.dart';
import 'package:pillpal/firebase_options.dart';
import 'app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';

const primaryColor = Color.fromARGB(255, 255, 0, 0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

// Change MaterialApp to MaterialApp.router and add the routerConfig
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      child: MaterialApp(
        title: 'PillPal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: primaryColor,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => UserPage(),
      },
      ),
    );
  }
}
