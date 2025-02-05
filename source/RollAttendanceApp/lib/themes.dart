import 'package:flutter/material.dart';

ThemeData customLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green, // Màu chủ đạo (Xanh lá)
  scaffoldBackgroundColor: const Color(0xFFE9FCe9), // Nền sáng

  /// AppBar
  appBarTheme: const AppBarTheme(
    color: Color(0xFFE9FCe9),
    iconTheme: IconThemeData(color: Colors.black), // Màu icon trên AppBar
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  /// TextField Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white, // Màu nền của TextField
    labelStyle: const TextStyle(color: Colors.green), // Màu chữ label khi không focus
    floatingLabelStyle: const TextStyle(color: Colors.green), // Màu chữ khi label nổi lên
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.green, width: 2), // Viền xanh khi focus
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),

  /// Text Selection (Khi chọn văn bản)
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.green, // Màu con trỏ nháy
    selectionColor: Colors.green.shade200, // Màu nền khi chọn text
    selectionHandleColor: Colors.green, // Màu thanh kéo khi chọn text
  ),

  /// Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8),
      // ),
      // padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),

  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.green, // Màu nền nút mặc định
    textTheme: ButtonTextTheme.primary,
  ),

  /// Floating Action Button (FAB)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.green, // Màu nền FAB
    foregroundColor: Colors.white, // Màu icon trên FAB
  ),

  /// BottomSheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white, // Nền của BottomSheet
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),

  /// Text Theme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black), // Chữ đen cho nội dung chính
    bodyMedium: TextStyle(color: Colors.black), // Chữ đen cho body
    headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Tiêu đề
  ),
);

ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.green, // Màu chủ đạo (Xanh lá)
  scaffoldBackgroundColor: const Color(0xFF121212), // Nền tối

  /// AppBar
  appBarTheme: const AppBarTheme(
    color: const Color(0xFF121212), // Màu nền AppBar
    iconTheme: IconThemeData(color: Colors.white), // Màu icon trên AppBar
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ), // Màu chữ AppBar
  ),

  /// TextField Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.black12, // Màu nền của TextField trong dark mode
    labelStyle: const TextStyle(color: Colors.green), // Màu chữ label khi không focus
    floatingLabelStyle: const TextStyle(color: Colors.green), // Màu chữ khi label nổi lên
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.green, width: 2), // Viền xanh khi focus
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),

  /// Text Selection (Khi chọn văn bản)
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.green, // Màu con trỏ nháy
    selectionColor: Colors.green.shade700, // Màu nền khi chọn text
    selectionHandleColor: Colors.green, // Màu thanh kéo khi chọn text
  ),

  /// Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8),
      // ),
      // padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),

  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.green, // Màu nền nút mặc định
    textTheme: ButtonTextTheme.primary,
  ),

  /// Floating Action Button (FAB)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.green, // Màu nền FAB
    foregroundColor: Colors.white, // Màu icon trên FAB
  ),

  /// BottomSheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E), // Nền của BottomSheet trong dark mode
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),

  /// Text Theme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // Chữ trắng cho nội dung chính
    bodyMedium: TextStyle(color: Colors.white), // Chữ trắng cho body
    headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Tiêu đề
  ),
);
