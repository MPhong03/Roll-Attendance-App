import 'package:intl/intl.dart';

class FormatUtils {
  // DATE TIME
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }
}
