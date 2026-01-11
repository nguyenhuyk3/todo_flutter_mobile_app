import 'package:intl/intl.dart';

String convertToDDMMYYYY(String dateString) {
  final inputFormat = DateFormat('yyyy-MM-dd');
  final outputFormat = DateFormat('dd-MM-yyyy');
  final dateTime = inputFormat.parse(dateString);

  return outputFormat.format(dateTime);
}
