import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:recipie_app/pages/main_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart'; // Fixed import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure the app is locked to portrait mode before the runApp call
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        // Primary color used across the app
        primarySwatch: Colors.blue,
        // Primary color with specific shade
        primaryColor: const Color(0xFF50A1FF),
        // Background color for major parts of the app
        primaryColorLight: Colors.blue.shade200,
        scaffoldBackgroundColor: Colors.white,
        // Accent color for buttons and interactive elements
        primaryColorDark: Colors.blue.shade800,
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade800,
          elevation: 0,
        ),
      ),
      home: Builder(
        builder: (context) {
          Provider.of<UserProvider>(context, listen: false).loadUserDetails();
          return MainScreen();
        },
      ),
    );
  }
}
