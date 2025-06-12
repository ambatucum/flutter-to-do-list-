import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'homescreen.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';

// Color palette sesuai gambar
const Color kCream = Color(0xFFFFF6E6); // background
const Color kRed = Color(0xFFFF3C2A); // judul
const Color kBlue = Color(0xFF3A7CA5);
const Color kYellow = Color(0xFFFFD166);
const Color kBlack = Color(0xFF222222);
const Color kSoftPink = Color(0xFFF7C5CC);

final ThemeData myTheme = ThemeData(
  scaffoldBackgroundColor: kCream,
  primaryColor: kRed,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kRed,
    primary: kRed,
    secondary: kBlue,
    background: kCream,
    onPrimary: Colors.white,
    onSecondary: kBlack,
  ),
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    headlineLarge: GoogleFonts.fredoka(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: kRed,
    ),
    titleLarge: GoogleFonts.fredoka(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: kRed,
    ),
    bodyMedium: GoogleFonts.poppins(fontSize: 16, color: kBlack),
    bodySmall: GoogleFonts.poppins(fontSize: 14, color: kBlack),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kRed,
    titleTextStyle: GoogleFonts.fredoka(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kBlue,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kRed),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kRed, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kRed),
    ),
    labelStyle: GoogleFonts.poppins(color: kBlack),
  ),
  cardTheme: CardTheme(
    color: kSoftPink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(kBlue),
    checkColor: MaterialStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dasker',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: const WelcomeScreen(),
    );
  }
}
