import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  dark,
  light,
}

final appThemes = {
  AppTheme.dark: ThemeData(
    primaryColor: Color(0xff5c93c4),
    accentColor: Color(0xff5c93c4),
    secondaryHeaderColor: Colors.grey,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
  ),
  AppTheme.light: ThemeData(
    primaryColor: Color(0xff5c93c4),
    splashColor: Color(0xDDFDEDF3),
    accentColor: Color(0xff5c93c4),
    scaffoldBackgroundColor: Color(0xffebeced ),
    canvasColor: Color(0xffebeced),
    secondaryHeaderColor: Colors.black,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
  ),
};
