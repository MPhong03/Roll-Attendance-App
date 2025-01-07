import 'package:flutter/material.dart';

enum AttendanceStatus {
  USER_PRESENTED,
  USER_ABSENTED,
  USER_PERMITTED_ABSENTED,
  USER_LATED
}

String getRoleName(AttendanceStatus role) {
  switch (role) {
    case AttendanceStatus.USER_PRESENTED:
      return 'Present';
    case AttendanceStatus.USER_ABSENTED:
      return 'Absented';
    case AttendanceStatus.USER_PERMITTED_ABSENTED:
      return 'Permitted Absented';
    case AttendanceStatus.USER_LATED:
      return 'Lated';
    default:
      return 'Unknown';
  }
}

int getRoleValue(AttendanceStatus role) {
  switch (role) {
    case AttendanceStatus.USER_PRESENTED:
      return 0;
    case AttendanceStatus.USER_ABSENTED:
      return 1;
    case AttendanceStatus.USER_PERMITTED_ABSENTED:
      return 2;
    case AttendanceStatus.USER_LATED:
      return 3;
    default:
      return -1;
  }
}

Map<String, dynamic> getRoleFromValue(int value) {
  switch (value) {
    case 0:
      return {'text': 'Present', 'color': Colors.green};
    case 1:
      return {'text': 'Absented', 'color': Colors.red};
    case 2:
      return {'text': 'Permitted Absented', 'color': Colors.blue};
    case 3:
      return {'text': 'Lated', 'color': Colors.orange};
    default:
      return {'text': 'Unknown', 'color': Colors.grey};
  }
}
