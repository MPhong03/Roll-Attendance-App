import 'package:flutter/material.dart';

ThemeData customLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green, // Màu chủ đạo (Xanh lá)
  scaffoldBackgroundColor: Colors.white, // Nền sáng
  appBarTheme: const AppBarTheme(
    color: Colors.green, // Màu AppBar
    iconTheme: IconThemeData(color: Colors.white), // Màu icon trên AppBar
    titleTextStyle:
        TextStyle(color: Colors.white, fontSize: 20), // Màu chữ AppBar
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black), // Chữ đen cho nội dung chính
    bodyMedium: TextStyle(color: Colors.black), // Chữ đen cho body
    headlineLarge:
        TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Tiêu đề
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.green, // Nền nút
  ),
);

ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.green, // Màu chủ đạo (Xanh lá)
  scaffoldBackgroundColor: Colors.black, // Nền tối
  appBarTheme: const AppBarTheme(
    color: Colors.green, // Màu AppBar
    iconTheme: IconThemeData(color: Colors.white), // Màu icon trên AppBar
    titleTextStyle:
        TextStyle(color: Colors.white, fontSize: 20), // Màu chữ AppBar
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // Chữ trắng cho nội dung chính
    bodyMedium: TextStyle(color: Colors.white), // Chữ trắng cho body
    headlineLarge:
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Tiêu đề
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.green, // Nền nút
  ),
);
